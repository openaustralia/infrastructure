terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.13.2"
    }
  }
}

module "env-blue" {
  source             = "../planningalerts-env"
  instance_count     = var.instance_count
  ami_name           = var.blue_ami_name
  enable             = var.blue_enabled
  env_name           = "blue"
  availability_zones = var.availability_zones
  security_groups = [
    var.security_group_behind_lb.name,
    aws_security_group.memcached_server.name,
    var.security_group_incoming_email.name
  ]
  iam_instance_profile = var.instance_profile.name
  key_name             = var.deployer_key.key_name
  vpc_id               = var.vpc.id
  zone_id              = var.zone_id
}

module "env-green" {
  source             = "../planningalerts-env"
  instance_count     = var.instance_count
  ami_name           = var.green_ami_name
  enable             = var.green_enabled
  env_name           = "green"
  availability_zones = var.availability_zones
  security_groups = [
    var.security_group_behind_lb.name,
    aws_security_group.memcached_server.name,
    var.security_group_incoming_email.name
  ]
  iam_instance_profile = var.instance_profile.name
  key_name             = var.deployer_key.key_name
  vpc_id               = var.vpc.id
  zone_id              = var.zone_id
}

# TODO: Delete this parameter group as soon as it's not used by the planningalerts db anymore
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

  # We're also disabling the forcing of ssl so that pgloader can do its business
  parameter {
    apply_method = "immediate"
    name         = "rds.force_ssl"
    value        = 0
  }
}

resource "aws_db_instance" "main" {
  # TODO: Less space should be needed in production
  # TODO: Enable storage autoscaling
  # TODO: Set maximum storage threshold to 200GB? 
  allocated_storage = 50

  # Using general purpose SSD
  storage_type   = "gp3"
  engine         = "postgres"
  engine_version = "15.5"
  # We can't specify iops when creating the database
  # This is the baseline for storage less than 400 GB
  iops = 3000

  # Even though db.m7g.large are available we can't use them
  # yet because we can't buy reserved instances for them. Sigh.
  instance_class          = "db.m6g.large"
  identifier              = "planningalerts"
  username                = "root"
  password                = var.rds_admin_password
  publicly_accessible     = false
  backup_retention_period = 35

  # We want 3-3:30am Sydney time which is 4-4:30pm GMT
  backup_window = "16:00-16:30"

  # We want Monday 4-4:30am Sydney time which is Sunday 5-5:30pm GMT.
  maintenance_window         = "Sun:17:00-Sun:17:30"
  multi_az                   = true
  auto_minor_version_upgrade = true

  apply_immediately   = false
  skip_final_snapshot = false

  # TODO: Limit traffic to only from planningalerts servers for production?
  vpc_security_group_ids = [var.security_group_postgresql.id]
  parameter_group_name   = "default.postgres15"

  # Enable performance insights
  performance_insights_enabled = true

  # Enable enhanced monitoring
  monitoring_role_arn = var.rds_monitoring_role.arn
  monitoring_interval = 60

  deletion_protection = true
}

resource "aws_elasticache_cluster" "main" {
  cluster_id = "planningalerts"
  engine     = "redis"
  # Smallest t3 available gives 0.5 GiB memory
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.sidekiq.name
  engine_version       = "6.2"
  port                 = 6379

  apply_immediately = false

  security_group_ids = [aws_security_group.redis.id]

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

resource "aws_acm_certificate" "main" {
  domain_name = "planningalerts.org.au"
  subject_alternative_names = [
    "www.planningalerts.org.au",
    "api.planningalerts.org.au"
  ]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in cloudflare_record.cert-validation-production : record.hostname]
}

# The production SSL certificate is currently the default cert on the load balancer

// Redirecting http://planningalerts.org.au -> https://planningalerts.org.au
// rather than straight to the canonical base url https://www.planningalerts.org.au
// to support HSTS. See https://hstspreload.org/
resource "aws_lb_listener_rule" "redirect-http-to-https" {
  listener_arn = var.listener_http.arn
  priority     = 1

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

resource "aws_lb_listener_rule" "redirect-https-to-canonical" {
  listener_arn = var.listener_https.arn
  priority     = 1

  action {
    type = "redirect"

    redirect {
      host        = "www.#{host}"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["planningalerts.org.au"]
    }
  }
}

resource "aws_lb_listener_rule" "main-https-redirect-sitemaps" {
  listener_arn = var.listener_https.arn
  priority     = 2

  action {
    type = "redirect"

    redirect {
      host        = aws_s3_bucket.sitemaps.bucket_regional_domain_name
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

resource "aws_lb_listener_rule" "forward" {
  listener_arn = var.listener_https.arn
  priority     = 3

  action {
    type = "forward"
    forward {
      target_group {
        arn    = module.env-blue.target_group_arn
        weight = var.blue_enabled ? var.blue_weight : 0
      }
      target_group {
        arn    = module.env-green.target_group_arn
        weight = var.green_enabled ? var.green_weight : 0
      }
      stickiness {
        enabled = false
        # The documentation and the tool disagree about whether duration is optional
        # I'm guessing i'm using an older version of terraform?
        duration = 1
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
      allowed_referrers = concat(
        [
          "https://planningalerts.org.au",
          "https://www.planningalerts.org.au",
          "https://cuttlefish.oaf.org.au",
          "http://localhost:3000",
        ],
        # Allows maps to work when accessing the servers directly (not through the load balancer)
        # Obviously not necessary for normal production use but useful for debugging and testing
        [for s in module.env-blue.public_names : "http://${s}:8000"],
        [for s in module.env-green.public_names : "http://${s}:8000"],
      )
    }
  }
}

resource "google_apikeys_key" "google_maps_server_key" {
  display_name = "PlanningAlerts Server API key (google_maps_server_key)"
  name         = "e401e298-4aa7-4ee8-a53e-06b6da107b2a"
  restrictions {
    server_key_restrictions {
      allowed_ips = concat(module.env-blue.public_ips, module.env-green.public_ips)
    }
  }
}

resource "aws_s3_bucket" "sitemaps" {
  bucket = "planningalerts-sitemaps-production"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sitemaps" {
  bucket = aws_s3_bucket.sitemaps.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_user" "sitemaps" {
  name = "planningalerts-sitemaps-production"
}

resource "aws_iam_access_key" "sitemaps" {
  user = aws_iam_user.sitemaps.name
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
  value     = aws_iam_access_key.sitemaps.secret
  sensitive = true
}

output "planningalerts_sitemaps_production_access_key_id" {
  value = aws_iam_access_key.sitemaps.id
}

resource "aws_iam_user_policy" "upload_to_sitemaps" {
  user = aws_iam_user.sitemaps.name
  name = "upload"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:PutObject",
            "s3:PutObjectAcl",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:s3:::${aws_s3_bucket.sitemaps.bucket}/*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

module "activestorage-s3" {
  source = "../planningalerts-activestorage-s3"

  name            = "planningalerts-as-production"
  allowed_origins = ["https://www.planningalerts.org.au"]
}

output "planningalerts_activestorage_s3_production_secret_access_key" {
  value     = module.activestorage-s3.secret_access_key
  sensitive = true
}

output "planningalerts_activestorage_s3_production_access_key_id" {
  value = module.activestorage-s3.access_key_id
}

# TODO: Move this to its own file

# In our setup we have a memcached server running alongside each webserver node
# so, each node acts as both a memcached client and server
resource "aws_security_group" "memcached_server" {
  name        = "planningalerts-memcached-server"
  description = "memcached servers for planningalerts"

  ingress {
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = [var.security_group_behind_lb.id]
  }
}

resource "aws_security_group" "redis" {
  name        = "redis-planningalerts"
  description = "Redis server for PlanningAlerts"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.security_group_behind_lb.id]
  }

  # Allow everything going out
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
