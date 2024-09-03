terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.13.2"
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
  security_groups         = [var.security_group_webserver.name]
  disable_api_termination = true
  iam_instance_profile    = var.instance_profile.name
}

moved {
  from = aws_instance.opengovernment
  to   = aws_instance.main
}

resource "aws_eip" "main" {
  instance = aws_instance.main.id
  tags = {
    Name = "opengovernment"
  }
}

moved {
  from = aws_eip.opengovernment
  to   = aws_eip.main
}
