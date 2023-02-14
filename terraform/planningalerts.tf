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
    Roles = "app,web,db"
  }
  security_groups         = [
    aws_security_group.planningalerts.name
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
    Roles = "app,web,db"
  }
  security_groups         = [
    aws_security_group.planningalerts.name
  ]
  iam_instance_profile    = aws_iam_instance_profile.logging.name

  availability_zone = var.availability_zones[count.index % 3]
}

resource "aws_elasticache_cluster" "planningalerts" {
  cluster_id           = "planningalerts"
  engine               = "redis"
  # Smallest t3 available gives 0.5 GiB memory
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.sidekiq.name
  engine_version       = "6.0.5"
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

resource "aws_lb_target_group" "planningalerts-production" {
  name     = "planningalerts-production"
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

resource "aws_lb_target_group" "planningalerts-staging" {
  name     = "planningalerts-staging"
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
  target_group_arn = aws_lb_target_group.planningalerts-production.arn
  target_id        = aws_instance.planningalerts-blue[count.index].id
}

resource "aws_lb_target_group_attachment" "planningalerts-green-production" {
  count = var.planningalerts_enable_green_env ? length(aws_instance.planningalerts-green) : 0
  target_group_arn = aws_lb_target_group.planningalerts-production.arn
  target_id        = aws_instance.planningalerts-green[count.index].id
}

resource "aws_lb_target_group_attachment" "planningalerts-blue-staging" {
  count = var.planningalerts_enable_blue_env ? length(aws_instance.planningalerts-blue) : 0
  target_group_arn = aws_lb_target_group.planningalerts-staging.arn
  target_id        = aws_instance.planningalerts-blue[count.index].id
}

resource "aws_lb_target_group_attachment" "planningalerts-green-staging" {
  count = var.planningalerts_enable_green_env ? length(aws_instance.planningalerts-green) : 0
  target_group_arn = aws_lb_target_group.planningalerts-staging.arn
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

resource "aws_lb_listener_rule" "redirect-http-to-planningalerts-production-canonical" {
  listener_arn = aws_lb_listener.main-http.arn

  action {
    type = "redirect"

    redirect {
      host        = "www.planningalerts.org.au"
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

# TODO: Rename
resource "aws_lb_listener_rule" "main-https-forward-planningalerts" {
  listener_arn = aws_lb_listener.main-https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.planningalerts-production.arn
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

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.planningalerts-staging.arn
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

resource "aws_lb_listener_rule" "redirect-https-to-planningalerts-canonical" {
  listener_arn = aws_lb_listener.main-https.arn

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
}

resource "aws_iam_user" "planningalerts_sitemaps_production" {
  name = "planningalerts-sitemaps-production"
}

resource "aws_iam_access_key" "planningalerts_sitemaps_production" {
  user = aws_iam_user.planningalerts_sitemaps_production.name
}

# These values are needed by ansible for planningalerts
output "planningalerts_sitemaps_production_secret_access_key" {
  value = aws_iam_access_key.planningalerts_sitemaps_production.secret
}

output "planningalerts_sitemaps_production_access_key_id" {
  value = aws_iam_access_key.planningalerts_sitemaps_production.id
}
