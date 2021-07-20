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
    type             = "forward"
    target_group_arn = aws_lb_target_group.planningalerts.arn
  }
}
