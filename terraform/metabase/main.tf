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

  instance_type = "t3.small"
  ebs_optimized = true
  key_name      = "deployer_key"
  tags = {
    Name = "metabase"
  }
  security_groups = [var.security_group_behind_lb.name]

  disable_api_termination = true
  iam_instance_profile    = var.instance_profile.name
}

resource "aws_eip" "main" {
  instance = aws_instance.main.id
  tags = {
    Name = "metabase"
  }
}

resource "cloudflare_record" "web" {
  zone_id = var.oaf_org_au_zone_id
  name    = "web.metabase.oaf.org.au"
  type    = "A"
  value   = aws_eip.main.public_ip
}

resource "cloudflare_record" "root" {
  zone_id = var.oaf_org_au_zone_id
  name    = "metabase.oaf.org.au"
  type    = "CNAME"
  value   = var.load_balancer.dns_name
}

resource "aws_lb_target_group" "main" {
  name     = "metabase"
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
  source             = "../aws-certificate"
  oaf_org_au_zone_id = var.oaf_org_au_zone_id
}

moved {
  from = aws_acm_certificate.main
  to   = module.certificate.aws_acm_certificate.main
}

moved {
  from = cloudflare_record.cert_validation
  to   = module.certificate.cloudflare_record.cert_validation
}

moved {
  from = aws_acm_certificate_validation.main
  to   = module.certificate.aws_acm_certificate_validation.main
}

resource "aws_lb_listener_certificate" "main" {
  listener_arn    = var.listener_https.arn
  certificate_arn = module.certificate.certificate.arn
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = var.listener_https.arn
  priority     = 5

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = [
        "metabase.oaf.org.au"
      ]
    }
  }
}








