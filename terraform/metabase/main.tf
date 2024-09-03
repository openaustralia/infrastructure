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

moved {
  from = aws_instance.metabase
  to   = aws_instance.main
}

resource "aws_eip" "main" {
  instance = aws_instance.main.id
  tags = {
    Name = "metabase"
  }
}

moved {
  from = aws_eip.metabase
  to   = aws_eip.main
}

resource "cloudflare_record" "web" {
  zone_id = var.oaf_org_au_zone_id
  name    = "web.metabase.oaf.org.au"
  type    = "A"
  value   = aws_eip.main.public_ip
}

moved {
  from = cloudflare_record.web_metabase
  to   = cloudflare_record.web
}

resource "cloudflare_record" "root" {
  zone_id = var.oaf_org_au_zone_id
  name    = "metabase.oaf.org.au"
  type    = "CNAME"
  value   = var.load_balancer.dns_name
}

moved {
  from = cloudflare_record.metabase
  to   = cloudflare_record.root
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

moved {
  from = aws_lb_target_group.metabase
  to   = aws_lb_target_group.main
}

resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.main.id
}

moved {
  from = aws_lb_target_group_attachment.metabase
  to   = aws_lb_target_group_attachment.main
}

# TODO: Extract certificate generation into module
resource "aws_acm_certificate" "main" {
  domain_name       = "metabase.oaf.org.au"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

moved {
  from = aws_acm_certificate.metabase
  to   = aws_acm_certificate.main
}

# Certification validation data
resource "cloudflare_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.oaf_org_au_zone_id
  name    = each.value.name
  type    = each.value.type
  value   = trimsuffix(each.value.record, ".")
  ttl     = 60
}

moved {
  from = cloudflare_record.metabase_cert_validation
  to   = cloudflare_record.cert_validation
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in cloudflare_record.cert_validation : record.hostname]
}

moved {
  from = aws_acm_certificate_validation.metabase
  to   = aws_acm_certificate_validation.main
}

resource "aws_lb_listener_certificate" "main" {
  listener_arn    = var.listener_https.arn
  certificate_arn = aws_acm_certificate.main.arn
}

moved {
  from = aws_lb_listener_certificate.metabase
  to   = aws_lb_listener_certificate.main
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

moved {
  from = aws_lb_listener_rule.metabase
  to   = aws_lb_listener_rule.main
}
