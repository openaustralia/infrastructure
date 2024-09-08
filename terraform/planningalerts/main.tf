terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4.0"
    }
  }
}

module "blue" {
  source             = "./env"
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
  zone_id              = cloudflare_zone.main.id
}

module "green" {
  source             = "./env"
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
  zone_id              = cloudflare_zone.main.id
}

module "activestorage-s3" {
  source = "../activestorage-s3"

  name            = "planningalerts-as-production"
  allowed_origins = ["https://www.planningalerts.org.au"]
}

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
