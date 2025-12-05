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

  instance_type = "t3.micro"
  ebs_optimized = true
  key_name      = "deployer_key"
  tags = {
    Name = "opengovernment"
  }
  vpc_security_group_ids  = [var.security_group_webserver.id, var.security_group_service.id]
  disable_api_termination = true
  iam_instance_profile    = var.instance_profile.name
}

resource "aws_eip" "main" {
  instance = aws_instance.main.id
  tags = {
    Name = "opengovernment"
  }
}
