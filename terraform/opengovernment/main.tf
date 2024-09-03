terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.13.2"
    }
  }
}

resource "aws_instance" "opengovernment" {
  ami = var.ami

  instance_type = "t3.micro"
  ebs_optimized = true
  key_name      = "deployer_key"
  tags = {
    Name = "opengovernment"
  }
  security_groups         = [var.security_group_webserver.name]
  disable_api_termination = true
  iam_instance_profile    = var.instance_profile.name
}

resource "aws_eip" "opengovernment" {
  instance = aws_instance.opengovernment.id
  tags = {
    Name = "opengovernment"
  }
}
