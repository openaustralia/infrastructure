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

  subnets = data.aws_subnets.default.ids

  enable_deletion_protection = true
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

resource "aws_lb_listener" "main-https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  # Choosing an SSL security policy for compatibility (and it's the AWS suggested default)
  # TODO: Do we want a more secure SSL security policy?
  # See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html
  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = module.planningalerts.certificate_production.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Unexpected host in header"
      status_code  = "400"
    }
  }
}
