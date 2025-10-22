terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4.0"
    }
  }
}

# New Right to Know Production Server on Ubuntu 22.04
# This creates a parallel production environment for Right to Know 

resource "aws_instance" "production" {
  ami = var.ubuntu_22_ami
  instance_type = "t3.large"
  ebs_optimized = true
  key_name      = "terraform"

  tags = {
    Name = "righttoknow-production"
    Environment = "production"
    Purpose = "Ubuntu 22.04 Production Server"
  }
  
  security_groups = [
    var.security_group_webserver.name,
    var.security_group_incoming_email.name,
  ]
  
  availability_zone       = aws_ebs_volume.data.availability_zone
  iam_instance_profile    = var.instance_profile.name

# Disable termination to protect production
  disable_api_termination = true
}

resource "aws_eip" "production" {
  instance = aws_instance.production.id
  tags = {
    Name = "righttoknow-production"
    Environment = "production"
  }
}

resource "aws_ebs_volume" "production_data" {
  availability_zone = "ap-southeast-2c"

  size = 240
  type = "gp3"
  tags = {
    Name = "righttoknow_production_data"
    Environment = "production"
  }
}

resource "aws_volume_attachment" "production_data" {
  device_name = "/dev/sdi"
  volume_id   = aws_ebs_volume.production_data.id
  instance_id = aws_instance.production.id
}
