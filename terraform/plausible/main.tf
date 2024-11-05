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

  # TODO: Check what instance size we're actually going to need here
  instance_type = "t3.small"
  ebs_optimized = true
  key_name      = "deployer_key"
  tags = {
    Name = "plausible"
  }
  security_groups = [var.security_group_behind_lb.name]

  # TODO: Uncomment this for production
  # disable_api_termination = true
  iam_instance_profile = var.instance_profile.name
}

resource "aws_eip" "main" {
  instance = aws_instance.main.id
  tags = {
    Name = "plausible"
  }
}

resource "cloudflare_record" "web" {
  zone_id = var.zone_id
  name    = "web.plausible.oaf.org.au"
  type    = "A"
  value   = aws_eip.main.public_ip
}

resource "cloudflare_record" "root" {
  zone_id = var.zone_id
  name    = "plausible.oaf.org.au"
  type    = "CNAME"
  value   = var.load_balancer.dns_name
}

resource "aws_lb_target_group" "main" {
  name     = "plausible"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc.id

  health_check {
    path                = "/api/health"
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.main.id
}

module "certificate" {
  source                    = "../aws-certificate"
  zone_id                   = var.zone_id
  domain_name               = "plausible.oaf.org.au"
  subject_alternative_names = []
}

resource "aws_lb_listener_certificate" "main" {
  listener_arn    = var.listener_https.arn
  certificate_arn = module.certificate.certificate.arn
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = var.listener_https.arn
  priority     = 7

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = [
        "plausible.oaf.org.au"
      ]
    }
  }
}
