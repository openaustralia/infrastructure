terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4.0"
    }
  }
}

data "aws_ami" "main" {
  owners = ["self"]
  filter {
    name   = "name"
    values = [var.ami_name]
  }
}

resource "aws_instance" "main" {
  count = var.enable ? var.instance_count : 0
  ami   = data.aws_ami.main.id

  instance_type = "t3.medium"
  ebs_optimized = true
  key_name      = var.key_name
  tags = {
    Name = "web${count.index + 1}.${var.env_name}.planningalerts"
    # The Application and Roles tag are used by capistrano-aws to figure out which instances to deploy to
    Application = "planningalerts"
    BlueGreen   = var.env_name
    Roles       = "app,web,db"
    # Same value across every instance in the blue/green fleet, unlike Name - see group_vars/ssm.yml
    PublicHostname = "www.planningalerts.org.au"
    # Deliberately mirrors Name (not the old static-inventory hostname, unlike other services) -
    # this fleet's instances get replaced regularly (blue/green cutovers), so a snapshot of the
    # previous ec2-*.compute.amazonaws.com hostname would likely go stale before the next
    # replacement anyway, whereas Name stays self-consistent regardless of replacement. Costs a
    # one-time CloudWatch log stream rename now - see the PR description for exactly what renamed
    # to what.
    LogName = "web${count.index + 1}.${var.env_name}.planningalerts"
    # Flattened inventory/ec2-hosts group membership, including groups only reached via
    # :children (requires_postgresql) - see inventory/aws_ec2.yml. Now includes "ec2" (previously
    # deliberately excluded) - that exclusion's stated reason (group_vars/ec2.yml's base_domain
    # "newly applying") doesn't hold up: the role already builds planningalerts.{{ base_domain }}
    # expecting exactly ec2.yml's org.au, and packer/planningalerts.pkr.hcl's own AMI-build
    # provisioner already runs with groups = ["ec2", "planningalerts"] - so the golden image
    # itself has always been built assuming ec2.yml's vars apply. Without "ec2" here, the live
    # instance was missing base_domain/aws_access_key/aws_secret_key/newrelic_license_key/
    # planningalerts_db_host entirely (the last of these registered by the "Gather RDS facts"
    # play, itself scoped to hosts: ec2) - which is what broke the newrelic_license_key check.
    AnsibleGroups = "planningalerts,requires_postgresql,ec2"
  }
  security_groups      = var.security_groups
  iam_instance_profile = var.iam_instance_profile

  availability_zone = var.availability_zones[count.index % 3]
}

resource "aws_lb_target_group" "main" {
  name     = "planningalerts-production-${var.env_name}"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/health_check"
    # Increasing from the default of 5 to handle occasional slow downs we're
    # seeing at the moment
    # TODO: Can we drop this down again to the default?
    timeout             = 10
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "main" {
  count            = var.enable ? var.instance_count : 0
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.main[count.index].id
}

resource "cloudflare_record" "main" {
  count   = var.enable ? var.instance_count : 0
  zone_id = var.zone_id
  name    = "web${count.index + 1}.${var.env_name}.planningalerts.org.au"
  type    = "A"
  value   = aws_instance.main[count.index].public_ip
}
