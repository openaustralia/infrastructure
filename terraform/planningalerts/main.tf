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

# TODO: These need to be output by the top level!

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
