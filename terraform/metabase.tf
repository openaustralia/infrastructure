resource "aws_instance" "metabase" {
  ami = var.ubuntu_22_ami

  instance_type = "t3.small"
  ebs_optimized = true
  key_name      = "deployer_key"
  tags = {
    Name = "metabase"
  }
  # This security group also lets in port 9000 for staging which we're not using
  security_groups = [aws_security_group.planningalerts.name]

  disable_api_termination = true
  iam_instance_profile = aws_iam_instance_profile.logging.name
}

resource "aws_eip" "metabase" {
  instance = aws_instance.metabase.id
  tags = {
    Name = "metabase"
  }
}

resource "aws_lb_target_group" "metabase" {
  name     = "metabase"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id

  health_check {
    path = "/api/health"
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "metabase" {
  target_group_arn = aws_lb_target_group.metabase.arn
  target_id        = aws_instance.metabase.id
}

resource "aws_acm_certificate" "metabase" {
  domain_name       = "metabase.oaf.org.au"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Certification validation data
resource "cloudflare_record" "metabase_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.metabase.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "metabase" {
  certificate_arn         = aws_acm_certificate.metabase.arn
  validation_record_fqdns = [for record in cloudflare_record.metabase_cert_validation : record.hostname]
}

resource "aws_lb_listener_certificate" "metabase" {
  listener_arn    = aws_lb_listener.main-https.arn
  certificate_arn = aws_acm_certificate.metabase.arn
}

resource "aws_lb_listener_rule" "metabase" {
  listener_arn = aws_lb_listener.main-https.arn
  priority = 5

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metabase.arn
  }

  condition {
    host_header {
      values = [
        "metabase.oaf.org.au"
      ]
    }
  }
}
