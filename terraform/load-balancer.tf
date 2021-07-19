# We're currently just planning to use a load balancer for planning alerts
# but we could use a single load balancer (I think) across all our services
# which would have the advantage that we could also do some clever routing
# if we wanted to and we could use the load balancer for serving SSL for
# everything

resource "aws_lb" "main" {
  name               = "main"
  internal           = false
  load_balancer_type = "application"

  subnets = data.aws_subnet_ids.default.ids
}

resource "aws_default_vpc" "default" {
}

data "aws_subnet_ids" "default" {
  vpc_id = aws_default_vpc.default.id
}
