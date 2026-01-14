# New OpenAustralia Production Server on Ubuntu 24.04
# This creates a parallel production environment for OpenAustralia

# After discussion with Brenda, this new server will house both staging and production.

resource "aws_instance" "production" {
  ami = var.ubuntu_24_ami

  instance_type = "t3.small"
  ebs_optimized = true
  key_name      = "test"
  tags = {
    Name = "openaustralia"
  }

  # Increase root volume size to 20GB to allow for more packages and data
  root_block_device {
    volume_size = 20
  }

  vpc_security_group_ids  = [var.security_group_webserver.id, var.security_group_service.id]
  availability_zone       = aws_ebs_volume.data.availability_zone
  disable_api_termination = true
  iam_instance_profile    = var.instance_profile.name
}

resource "aws_eip" "production" {
  instance = aws_instance.production.id
  tags = {
    Name = "openaustralia-prod"
  }
}

# We'll create a seperate EBS volume for all the application
# data that can not be regenerated. e.g. parliamentary XML,
# register of members interests scans, etc..

resource "aws_ebs_volume" "production_data" {
  availability_zone = "ap-southeast-2c"

  # 10 Gb is an educated guess based on seeing how much space is taken up
  # on kedumba.
  # After loading real data in we upped it to 20GB
  size = 20
  type = "gp3"
  tags = {
    Name = "openaustralia_data"
  }
}

resource "aws_volume_attachment" "production_data" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.production_data.id
  instance_id = aws_instance.production.id
}
