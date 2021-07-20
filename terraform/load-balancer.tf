# We're currently just planning to use a load balancer for planning alerts
# but we could use a single load balancer (I think) across all our services
# which would have the advantage that we could also do some clever routing
# if we wanted to and we could use the load balancer for serving SSL for
# everything

resource "aws_lb" "main" {
  name               = "main"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load-balancer.id]

  subnets = data.aws_subnet_ids.default.ids
}

resource "aws_lb_listener" "main-http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_rule" "redirect-http-to-planningalerts-staging-canonical" {
  listener_arn = aws_lb_listener.main-http.arn

  action {
    type = "redirect"

    redirect {
      host        = "www.test.planningalerts.org.au"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["test.planningalerts.org.au", "www.test.planningalerts.org.au"]
    }
  }
}

resource "aws_lb_listener_rule" "forward-http-planningalerts-api-staging" {
  listener_arn = aws_lb_listener.main-http.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.planningalerts.arn
  }

  condition {
    host_header {
      values = ["api.test.planningalerts.org.au"]
    }
  }
}

resource "aws_lb_listener" "main-https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  # Choosing an SSL security policy for compatibility (and it's the AWS suggested default)
  # TODO: Do we want a more secure SSL security policy?
  # See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.planningalerts-production.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.planningalerts.arn
  }
}

resource "aws_lb_listener_rule" "redirect-https-to-planningalerts-staging-canonical" {
  listener_arn = aws_lb_listener.main-https.arn

  action {
    type = "redirect"

    redirect {
      host        = "www.test.planningalerts.org.au"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["test.planningalerts.org.au"]
    }
  }
}

resource "aws_lb_listener_certificate" "planningalerts-staging" {
  listener_arn    = aws_lb_listener.main-https.arn
  certificate_arn = aws_acm_certificate.planningalerts-staging.arn
}
