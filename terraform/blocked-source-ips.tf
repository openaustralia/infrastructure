# Source IP ranges blocked at the load balancer with a 403.
#
# These rules were added directly in the AWS console as an emergency response and
# are recorded here so they're explicit, reviewable, and removed deliberately rather
# than by accident. They sit at priorities 1-4, ahead of every routing rule on the
# HTTPS listener, so blocked traffic never reaches an application.
#
# The grouping of CIDRs across the four rules matches what was created in the console.
# Each ALB rule condition allows a limited number of values, so ranges were added in
# batches as they were identified.
#
# The `import` blocks below adopt the existing rules into Terraform state rather than
# creating new ones. They are a no-op once applied and can be deleted after that.

resource "aws_lb_listener_rule" "blocked_source_ips_1" {
  listener_arn = aws_lb_listener.main-https.arn
  priority     = 1

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }

  condition {
    source_ip {
      values = [
        "43.173.176.0/22",
        "43.173.180.0/23",
        "43.173.182.0/24",
      ]
    }
  }
}

resource "aws_lb_listener_rule" "blocked_source_ips_2" {
  listener_arn = aws_lb_listener.main-https.arn
  priority     = 2

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }

  condition {
    source_ip {
      values = [
        "43.172.194.0/23",
        "43.172.196.0/23",
        "43.172.198.0/24",
      ]
    }
  }
}

resource "aws_lb_listener_rule" "blocked_source_ips_3" {
  listener_arn = aws_lb_listener.main-https.arn
  priority     = 3

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }

  condition {
    source_ip {
      values = [
        "43.173.173.0/24",
        "43.173.174.0/23",
        "155.117.163.0/24",
      ]
    }
  }
}

resource "aws_lb_listener_rule" "blocked_source_ips_4" {
  listener_arn = aws_lb_listener.main-https.arn
  priority     = 4

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }

  condition {
    source_ip {
      values = [
        "167.148.117.0/24",
      ]
    }
  }
}

import {
  to = aws_lb_listener_rule.blocked_source_ips_1
  id = "arn:aws:elasticloadbalancing:ap-southeast-2:924104513718:listener-rule/app/main/849a14c4221ca5aa/72e3742ac1d27ba5/ee1f77e92714910e"
}

import {
  to = aws_lb_listener_rule.blocked_source_ips_2
  id = "arn:aws:elasticloadbalancing:ap-southeast-2:924104513718:listener-rule/app/main/849a14c4221ca5aa/72e3742ac1d27ba5/4fa21e780fccf5a1"
}

import {
  to = aws_lb_listener_rule.blocked_source_ips_3
  id = "arn:aws:elasticloadbalancing:ap-southeast-2:924104513718:listener-rule/app/main/849a14c4221ca5aa/72e3742ac1d27ba5/46780b135a3a4302"
}

import {
  to = aws_lb_listener_rule.blocked_source_ips_4
  id = "arn:aws:elasticloadbalancing:ap-southeast-2:924104513718:listener-rule/app/main/849a14c4221ca5aa/72e3742ac1d27ba5/e7f0ef90383f0369"
}
