# RightToKnow Staging Infrastructure for Ubuntu 22.04 Testing
# This creates a parallel staging environment to test the migration

resource "aws_instance" "staging" {
  ami           = var.ubuntu_22_ami
  instance_type = "t3.medium"  # Start smaller for staging
  key_name      = "terraform"
  
  tags = {
    Name        = "righttoknow-staging"
    Environment = "staging"
    Purpose     = "Ubuntu 22.04 Staging Server"
  }
  
  # Increase root volume size to 20GB to allow for more packages and data
  root_block_device {
    volume_size = 20
  }
  
  security_groups = [
    var.security_group_webserver.name,
    var.security_group_incoming_email.name,
  ]
  
  availability_zone    = aws_ebs_volume.staging_data.availability_zone
  iam_instance_profile = var.instance_profile.name
  
  # Allow termination for staging
  disable_api_termination = false
}

resource "aws_eip" "staging" {
  instance = aws_instance.staging.id
  tags = {
    Name        = "righttoknow-staging"
    Environment = "staging"
  }
}

resource "aws_ebs_volume" "staging_data" {
  availability_zone = "ap-southeast-2c"  # Same AZ as production
  
  size = 10  # 10GB for staging as requested
  type = "gp3"
  tags = {
    Name        = "righttoknow_staging_data"
    Environment = "staging"
  }
}

resource "aws_volume_attachment" "staging_data" {
  device_name = "/dev/sdi"
  volume_id   = aws_ebs_volume.staging_data.id
  instance_id = aws_instance.staging.id
}
