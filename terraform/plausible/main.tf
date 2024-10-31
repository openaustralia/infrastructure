terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4.0"
    }
  }
}

resource "aws_instance" "main" {
  ami = var.ami

  # TODO: Check what instance size we're actually going to need here
  instance_type = "t3.small"
  ebs_optimized = true
  key_name      = "deployer_key"
  tags = {
    Name = "plausible"
  }
  security_groups = [var.security_group_behind_lb.name]

  # TODO: Uncomment this for production
  # disable_api_termination = true
  iam_instance_profile = var.instance_profile.name
}

resource "aws_eip" "main" {
  instance = aws_instance.main.id
  tags = {
    Name = "plausible"
  }
}

resource "cloudflare_record" "web" {
  zone_id = var.zone_id
  name    = "web.plausible.oaf.org.au"
  type    = "A"
  value   = aws_eip.main.public_ip
}

