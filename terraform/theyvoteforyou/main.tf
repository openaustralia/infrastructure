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

  # Increased to t3.xlarge because of performance issues (and nasty bots) in the run up to the 2025 Federal election
  # TODO: Probably want to drop it back down once the flurry has passed
  instance_type = "t3.xlarge"
  ebs_optimized = true
  key_name      = var.deployer_key.key_name
  tags = {
    Name = "theyvoteforyou"
  }
  security_groups         = [var.security_group.name]
  disable_api_termination = true
  iam_instance_profile    = var.instance_profile.name
  # Setting the availability zone because it needs to be the same as the disk
  availability_zone = "ap-southeast-2a"
}

resource "aws_eip" "main" {
  instance = aws_instance.main.id
  tags = {
    Name = "theyvoteforyou"
  }
}

resource "aws_ebs_volume" "data" {
  availability_zone = aws_instance.main.availability_zone

  size = 30
  type = "gp3"
  tags = {
    Name = "theyvoteforyou_data"
  }
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdi"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.main.id
}
