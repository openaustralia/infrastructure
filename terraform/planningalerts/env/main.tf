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
