variable "availability_zones" {
  type    = list(string)
  default = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

resource "aws_instance" "planningalerts-blue" {
  count = var.planningalerts_enable_blue_env ? var.planningalerts_blue_instance_count : 0
  ami = var.planningalerts_blue_ami

  instance_type = "t3.medium"
  ebs_optimized = true
  key_name      = aws_key_pair.deployer.key_name
  tags = {
    Name = "web${count.index+1}.blue.planningalerts"
    # The Application and Roles tag are used by capistrano-aws to figure out which instances to deploy to
    Application = "planningalerts"
    BlueGreen = "blue"
    Roles = "app,web,db"
  }
  security_groups         = [
    aws_security_group.planningalerts.name,
    aws_security_group.planningalerts_memcached_server.name
  ]
  iam_instance_profile    = aws_iam_instance_profile.logging.name

  availability_zone = var.availability_zones[count.index % 3]
}

resource "aws_instance" "planningalerts-green" {
  count = var.planningalerts_enable_green_env ? var.planningalerts_green_instance_count : 0
  ami = var.planningalerts_green_ami

  instance_type = "t3.medium"
  ebs_optimized = true
  key_name      = aws_key_pair.deployer.key_name
  tags = {
    Name = "web${count.index+1}.green.planningalerts"
    # The Application and Roles tag are used by capistrano-aws to figure out which instances to deploy to
    Application = "planningalerts"
    BlueGreen = "green"
    Roles = "app,web,db"
  }
  security_groups         = [
    aws_security_group.planningalerts.name,
    aws_security_group.planningalerts_memcached_server.name
  ]
  iam_instance_profile    = aws_iam_instance_profile.logging.name

  availability_zone = var.availability_zones[count.index % 3]
}

resource "aws_db_parameter_group" "md5" {
    description = "Allow access via md5 for pgloader"
    family      = "postgres15"
    name        = "md5"

    # With this setting new passwords use the old md5 password hashing. We need
    # this set before passwords are created for the planningalerts postgresl roles
    # so that pgloader can access postgresql.
    # TODO: One migration is done we should switch this back to the default
    # This will probably involve just removing this parameter group and switching
    # back to the default
    parameter {
        apply_method = "immediate"
        name         = "password_encryption"
        value        = "md5"
    }
}

resource "aws_db_instance" "planningalerts" {
  # TODO: Less space should be needed in production
  # TODO: Enable storage autoscaling
  # TODO: Set maximum storage threshold to 200GB? 
  allocated_storage = 50

  # Using general purpose SSD
  storage_type   = "gp3"
  engine         = "postgres"
  engine_version = "15.2"
  # We can't specify iops when creating the database
  # This is the baseline for storage less than 400 GB
  iops = 3000

  # TODO: Upgrade instance_class to db.m6g.large for production (might be able to use smaller)
  instance_class          = "db.t4g.micro"
  identifier              = "planningalerts"
  username                = "root"
  password                = var.rds_admin_password
  # TODO: Change publicly_accessible to false for production
  publicly_accessible     = true
  backup_retention_period = 35

  # We want 3-3:30am Sydney time which is 4-4:30pm GMT
  backup_window = "16:00-16:30"

  # We want Monday 4-4:30am Sydney time which is Sunday 5-5:30pm GMT.
  maintenance_window         = "Sun:17:00-Sun:17:30"
  # TODO: Change multi_az to true for production
  multi_az                   = false
  auto_minor_version_upgrade = true

  # TODO: Change apply_immediately to false for production
  apply_immediately      = true
  # TODO: Change skip_final_snapshot to false for production
  skip_final_snapshot    = true

  # TODO: Turn on performance insights for production
  # TODO: Turn on enhanced monitoring for production

  # TODO: Limit traffic to only from planningalerts servers for production?
  vpc_security_group_ids = [aws_security_group.postgresql.id]
  # TODO: Probably switch back to default parameter group name for production
  parameter_group_name = aws_db_parameter_group.md5.name
}

resource "aws_elasticache_cluster" "planningalerts" {
  cluster_id           = "planningalerts"
  engine               = "redis"
  # Smallest t3 available gives 0.5 GiB memory
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.sidekiq.name
  engine_version       = "6.2.6"
  port                 = 6379

  apply_immediately    = false

  security_group_ids = [ aws_security_group.redis-planningalerts.id ]

  # We want Monday 4-5am Sydney time which is Sunday 5-6pm GMT.
  maintenance_window = "Sun:17:00-Sun:18:00"

  snapshot_retention_limit = 7

  # We want 2:30-3:30am Sydney time which is 3:30-4:30pm GMT
  snapshot_window = "15:30-16:30"
}

# Redis setup required for sidekiq.
# See https://github.com/mperham/sidekiq/wiki/Using-Redis
resource "aws_elasticache_parameter_group" "sidekiq" {
  name   = "sidekiq"
  family = "redis6.x"

  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }
}

resource "aws_lb_target_group" "planningalerts-production-blue" {
  name     = "planningalerts-production-blue"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id

  health_check {
    path = "/health_check"
    # Increasing from the default of 5 to handle occasional slow downs we're
    # seeing at the moment
    # TODO: Can we drop this down again to the default?
    timeout = 10
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "planningalerts-production-green" {
  name     = "planningalerts-production-green"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id

  health_check {
    path = "/health_check"
    # Increasing from the default of 5 to handle occasional slow downs we're
    # seeing at the moment
    # TODO: Can we drop this down again to the default?
    timeout = 10
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "planningalerts-staging-blue" {
  name     = "planningalerts-staging-blue"
  port     = 9000
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id

  health_check {
    path = "/health_check"
    # Increasing from the default of 5 to handle occasional slow downs we're
    # seeing at the moment
    # TODO: Can we drop this down again to the default?
    timeout = 10
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "planningalerts-staging-green" {
  name     = "planningalerts-staging-green"
  port     = 9000
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id

  health_check {
    path = "/health_check"
    # Increasing from the default of 5 to handle occasional slow downs we're
    # seeing at the moment
    # TODO: Can we drop this down again to the default?
    timeout = 10
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "planningalerts-blue-production" {
  count = var.planningalerts_enable_blue_env ? length(aws_instance.planningalerts-blue) : 0
  target_group_arn = aws_lb_target_group.planningalerts-production-blue.arn
  target_id        = aws_instance.planningalerts-blue[count.index].id
}

resource "aws_lb_target_group_attachment" "planningalerts-green-production" {
  count = var.planningalerts_enable_green_env ? length(aws_instance.planningalerts-green) : 0
  target_group_arn = aws_lb_target_group.planningalerts-production-green.arn
  target_id        = aws_instance.planningalerts-green[count.index].id
}

resource "aws_lb_target_group_attachment" "planningalerts-blue-staging" {
  count = var.planningalerts_enable_blue_env ? length(aws_instance.planningalerts-blue) : 0
  target_group_arn = aws_lb_target_group.planningalerts-staging-blue.arn
  target_id        = aws_instance.planningalerts-blue[count.index].id
}

resource "aws_lb_target_group_attachment" "planningalerts-green-staging" {
  count = var.planningalerts_enable_green_env ? length(aws_instance.planningalerts-green) : 0
  target_group_arn = aws_lb_target_group.planningalerts-staging-green.arn
  target_id        = aws_instance.planningalerts-green[count.index].id
}

resource "aws_acm_certificate" "planningalerts-production" {
  domain_name       = "planningalerts.org.au"
  subject_alternative_names = [
    "www.planningalerts.org.au",
    "api.planningalerts.org.au"
  ]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "planningalerts-staging" {
  domain_name       = "test.planningalerts.org.au"
  subject_alternative_names = [
    "www.test.planningalerts.org.au",
    "api.test.planningalerts.org.au"
  ]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "planningalerts-production" {
  certificate_arn         = aws_acm_certificate.planningalerts-production.arn
  validation_record_fqdns = [for record in cloudflare_record.cert-validation-production : record.hostname]
}

resource "aws_acm_certificate_validation" "planningalerts-staging" {
  certificate_arn         = aws_acm_certificate.planningalerts-staging.arn
  validation_record_fqdns = [for record in cloudflare_record.cert-validation-staging : record.hostname]
}

# The production SSL certificate is currently the default cert on the load balancer

resource "aws_lb_listener_certificate" "planningalerts-staging" {
  listener_arn    = aws_lb_listener.main-https.arn
  certificate_arn = aws_acm_certificate.planningalerts-staging.arn
}

// Redirecting http://planningalerts.org.au -> https://planningalerts.org.au
// rather than straight to the canonical base url https://www.planningalerts.org.au
// to support HSTS. See https://hstspreload.org/
resource "aws_lb_listener_rule" "planningalerts-redirect-http-to-https" {
  listener_arn = aws_lb_listener.main-http.arn
  priority = 1

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["planningalerts.org.au", "www.planningalerts.org.au"]
    }
  }
}

resource "aws_lb_listener_rule" "redirect-http-to-planningalerts-staging-canonical" {
  listener_arn = aws_lb_listener.main-http.arn
  priority = 2

  action {
    type = "redirect"

    redirect {
      host        = "www.test.planningalerts.org.au"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["test.planningalerts.org.au", "www.test.planningalerts.org.au"]
    }
  }
}

resource "aws_lb_listener_rule" "redirect-https-to-planningalerts-canonical" {
  listener_arn = aws_lb_listener.main-https.arn
  priority = 1

  action {
    type = "redirect"

    redirect {
      host        = "www.#{host}"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["planningalerts.org.au", "test.planningalerts.org.au"]
    }
  }
}

resource "aws_lb_listener_rule" "main-https-redirect-sitemaps-production" {
  listener_arn = aws_lb_listener.main-https.arn
  priority     = 2

  action {
    type  = "redirect"

    redirect {
      host = aws_s3_bucket.planningalerts_sitemaps_production.bucket_regional_domain_name
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }

  condition {
    host_header {
      values = [
        "www.planningalerts.org.au",
      ]
    }
  }
  condition {
    path_pattern {
      values = [
        "/sitemaps/*",
      ]
    }
  }
}

# TODO: Rename
resource "aws_lb_listener_rule" "main-https-forward-planningalerts" {
  listener_arn = aws_lb_listener.main-https.arn
  priority = 3

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.planningalerts-production-blue.arn
        weight = var.planningalerts_enable_blue_env ? var.planningalerts_blue_weight : 0
      }
      target_group {
        arn = aws_lb_target_group.planningalerts-production-green.arn
        weight = var.planningalerts_enable_green_env ? var.planningalerts_green_weight : 0
      }
    }
  }

  condition {
    host_header {
      values = [
        "www.planningalerts.org.au",
        "api.planningalerts.org.au"
      ]
    }
  }
}

resource "aws_lb_listener_rule" "main-https-forward-planningalerts-staging" {
  listener_arn = aws_lb_listener.main-https.arn
  priority = 4

  action {
    type             = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.planningalerts-staging-blue.arn
        weight = var.planningalerts_enable_blue_env ? var.planningalerts_blue_weight : 0
      }
      target_group {
        arn = aws_lb_target_group.planningalerts-staging-green.arn
        weight = var.planningalerts_enable_green_env ? var.planningalerts_green_weight : 0
      }
    }
  }

  condition {
    host_header {
      values = [
        "www.test.planningalerts.org.au",
        "api.test.planningalerts.org.au"
      ]
    }
  }
}

# TODO: Check usage of all these keys and how they are set up
# TODO: Probably all these keys could do with rotation. They've been in use for a while now.
resource "google_apikeys_key" "google_maps_email_key" {
    display_name = "PlanningAlerts Web API Key (google_maps_email_key)"
    name         = "8405437045225725397"

    restrictions {
        browser_key_restrictions {
            allowed_referrers = [
                "https://planningalerts.org.au",
                "https://www.planningalerts.org.au",
                "https://test.planningalerts.org.au",
                "https://www.test.planningalerts.org.au",
                "https://cuttlefish.oaf.org.au",
                "http://localhost:3000",
            ]
        }
    }
}

resource "google_apikeys_key" "google_maps_key" {
    display_name = "PlanningAlerts Web Static Street View key (google_maps_key)"
    name         = "3f2cc059-ec01-4c0a-bc43-a5e9d1daa993"

    restrictions {
        browser_key_restrictions {
            allowed_referrers = [
                "https://planningalerts.org.au",
                "https://www.planningalerts.org.au",
                "https://test.planningalerts.org.au",
                "https://www.test.planningalerts.org.au",
                "https://cuttlefish.oaf.org.au",
                "http://localhost:3000",
            ]
        }
    }
}

resource "google_apikeys_key" "google_maps_server_key" {
    display_name = "PlanningAlerts Server API key (google_maps_server_key)"
    name         = "e401e298-4aa7-4ee8-a53e-06b6da107b2a"
    restrictions {
        server_key_restrictions {
            allowed_ips = concat(aws_instance.planningalerts-blue[*].public_ip, aws_instance.planningalerts-green[*].public_ip)
        }
    }
}

resource "aws_s3_bucket" "planningalerts_sitemaps_production" {
  bucket = "planningalerts-sitemaps-production"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_iam_user" "planningalerts_sitemaps_production" {
  name = "planningalerts-sitemaps-production"
}

resource "aws_iam_access_key" "planningalerts_sitemaps_production" {
  user = aws_iam_user.planningalerts_sitemaps_production.name
}

# These values are needed by ansible for planningalerts
# They should be encrypted and put in group_vars/planningalerts.yml
# Take the output of this command:
# terraform output planningalerts_sitemaps_production_access_key_id
# cd ..; ansible-vault encrypt_string --name aws_access_key_id "value from above" --encrypt-vault-id default
# AND
# terraform output planningalerts_sitemaps_production_secret_access_key
# cd ..; ansible-vault encrypt_string --name aws_secret_access_key "value from above" --encrypt-vault-id default

output "planningalerts_sitemaps_production_secret_access_key" {
  value = aws_iam_access_key.planningalerts_sitemaps_production.secret
  sensitive = true
}

output "planningalerts_sitemaps_production_access_key_id" {
  value = aws_iam_access_key.planningalerts_sitemaps_production.id
}

resource "aws_iam_user_policy" "upload_to_planningalerts_sitemaps" {
  user   = aws_iam_user.planningalerts_sitemaps_production.name
  name   = "upload"
  policy = jsonencode(
    {
      Statement = [
        {
          Action   = [
            "s3:PutObject",
            "s3:PutObjectAcl",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:s3:::${aws_s3_bucket.planningalerts_sitemaps_production.bucket}/*"
        },
      ]
      Version   = "2012-10-17"
    }
  )
}