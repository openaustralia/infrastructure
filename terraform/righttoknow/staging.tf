# RightToKnow Staging Infrastructure for Ubuntu 22.04 Testing
# This creates a parallel staging environment to test the migration

resource "aws_instance" "staging" {
  ami           = var.ubuntu_22_ami
  instance_type = "t3.medium" # Start smaller for staging
  key_name      = "terraform"

  tags = {
    Name        = "righttoknow-staging"
    Environment = "staging"
    Purpose     = "Ubuntu 22.04 Staging Server"

    # Flattened inventory/ec2-hosts group membership, including groups only reached via
    # :children (righttoknow, catch_all_mail) - see inventory/aws_ec2.yml.
    AnsibleGroups = "righttoknow_staging,righttoknow,catch_all_mail,requires_postgresql,ec2"

    # Matches the exact old static-inventory hostname. (Backup continuity is actually carried
    # by LogName below - the restic repository path is derived from log_name, not
    # public_hostname; see roles/internal/righttoknow/meta/main.yml.)
    PublicHostname = "staging.righttoknow.org.au"

    # This host is already on the dynamic inventory, so there's no separate history to preserve -
    # matches inventory/ec2-hosts' commented-out entry for it either way.
    LogName = "staging.righttoknow.org.au"

    # Application, Stage and Roles will be read by the capistrano-aws gem (see
    # https://github.com/fernandocarletti/capistrano-aws#configuration) to find and configure
    # this deploy target for cap staging deploy - matches righttoknow/config/deploy.rb's
    # set :application and config/deploy/staging.rb's roles: %w[app web db].
    Application = "alaveteli"
    Stage       = "staging"
    Roles       = "app,web,db"
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
  availability_zone = "ap-southeast-2c" # Same AZ as production

  size = 10 # 10GB for staging as requested
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
