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
