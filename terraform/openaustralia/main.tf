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

  # Running sitemap generation (a ruby process, suprise, surprise) pegged the
  # memory usage on a t2.small. So, upping to a t2.medium.
  instance_type = "t3.small"
  ebs_optimized = true
  key_name      = "test"
  tags = {
    Name = "openaustralia"
  }
  security_groups         = [var.security_group_webserver.name]
  availability_zone       = aws_ebs_volume.data.availability_zone
  disable_api_termination = true
  iam_instance_profile    = var.instance_profile.name
}

resource "aws_eip" "main" {
  instance = aws_instance.main.id
  tags = {
    Name = "openaustralia"
  }
}

# We'll create a seperate EBS volume for all the application
# data that can not be regenerated. e.g. parliamentary XML,
# register of members interests scans, etc..

resource "aws_ebs_volume" "data" {
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

resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.main.id
}

# TODO: backup EBS volume by taking daily snapshots
# This can be automated using Cloudwatch. See:
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/TakeScheduledSnapshot.html
# https://www.terraform.io/docs/providers/aws/r/cloudwatch_event_rule.html
