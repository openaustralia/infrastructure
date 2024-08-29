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
  # Changed it from t2.small to t2.medium because provisioning was very slow
  # Changed from t2.medium to t2.large because it was running out of memory
  # when running script/rebuild-xapian-index
  # going back to t2.medium to see if we can get away with that
  # Going back to t2.large because we seem to be regularly OOMing after cleaning up the on-disk cache
  instance_type = "t3.large"
  ebs_optimized = true
  key_name      = "test"
  tags = {
    Name = "righttoknow"
  }
  security_groups = [
    var.security_group_webserver.name,
    var.security_group_incoming_email.name,
  ]
  availability_zone       = aws_ebs_volume.data.availability_zone
  disable_api_termination = true
  iam_instance_profile    = var.instance_profile.name
}

moved {
  from = aws_instance.righttoknow
  to   = aws_instance.main
}

resource "aws_eip" "main" {
  instance = aws_instance.main.id
  tags = {
    Name = "righttoknow"
  }
}

moved {
  from = aws_eip.righttoknow
  to   = aws_eip.main
}

resource "aws_ebs_volume" "data" {
  availability_zone = "ap-southeast-2c"

  size = 240
  type = "gp3"
  tags = {
    Name = "righttoknow_data"
  }
}

moved {
  from = aws_ebs_volume.righttoknow_data
  to   = aws_ebs_volume.data
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdi"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.main.id
}

moved {
  from = aws_volume_attachment.righttoknow_data
  to   = aws_volume_attachment.data
}
