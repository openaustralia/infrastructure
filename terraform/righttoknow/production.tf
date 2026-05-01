# New Right to Know Production Server on Ubuntu 22.04
# This creates a parallel production environment for Right to Know 

resource "aws_instance" "production" {
  ami           = var.ubuntu_22_ami
  instance_type = "t3.large"
  ebs_optimized = true
  key_name      = "terraform"

  tags = {
    Name        = "righttoknow-production"
    Environment = "production"
    Purpose     = "Ubuntu 22.04 Production Server"
  }

  # Increase root volume size to 20GB to allow for more packages and data
  root_block_device {
    volume_size = 20
  }

  vpc_security_group_ids = [
    var.security_group_webserver.id,
    var.security_group_service.id,
    var.security_group_incoming_email.id,
  ]

  availability_zone    = aws_ebs_volume.production_data.availability_zone
  iam_instance_profile = var.instance_profile.name

  # Disable termination to protect production
  disable_api_termination = true
}

resource "aws_eip" "production" {
  instance = aws_instance.production.id
  tags = {
    Name        = "righttoknow-production"
    Environment = "production"
  }
}

resource "aws_ebs_volume" "production_data" {
  availability_zone = "ap-southeast-2c"

  size = 240
  type = "gp3"
  tags = {
    Name        = "righttoknow_production_data"
    Environment = "production"
  }
}

resource "aws_volume_attachment" "production_data" {
  device_name = "/dev/sdi"
  volume_id   = aws_ebs_volume.production_data.id
  instance_id = aws_instance.production.id
}
