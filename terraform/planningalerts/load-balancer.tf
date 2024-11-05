// Redirecting http://planningalerts.org.au -> https://planningalerts.org.au
// rather than straight to the canonical base url https://www.planningalerts.org.au
// to support HSTS. See https://hstspreload.org/
resource "aws_lb_listener_rule" "redirect-http-to-https" {
  listener_arn = var.listener_http.arn
  priority     = 1

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["planningalerts.org.au", "www.planningalerts.org.au"]
    }
  }
}

resource "aws_lb_listener_rule" "redirect-https-to-canonical" {
  listener_arn = var.listener_https.arn
  priority     = 1

  action {
    type = "redirect"

    redirect {
      host        = "www.#{host}"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["planningalerts.org.au"]
    }
  }
}

resource "aws_lb_listener_rule" "main-https-redirect-sitemaps" {
  listener_arn = var.listener_https.arn
  priority     = 2

  action {
    type = "redirect"

    redirect {
      host        = aws_s3_bucket.sitemaps.bucket_regional_domain_name
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }

  condition {
    host_header {
      values = [
        "www.planningalerts.org.au",
      ]
    }
  }
  condition {
    path_pattern {
      values = [
        "/sitemaps/*",
      ]
    }
  }
}

resource "aws_lb_listener_rule" "plausible_script" {
  listener_arn = var.listener_https.arn
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = var.plausible_lb_target_group.arn
  }

  condition {
    host_header {
      values = [
        "www.planningalerts.org.au",
      ]
    }
  }
  condition {
    path_pattern {
      values = [
        "/js/script.*",
      ]
    }
  }
}

resource "aws_lb_listener_rule" "forward" {
  listener_arn = var.listener_https.arn
  priority     = 5

  action {
    type = "forward"
    forward {
      target_group {
        arn    = module.blue.target_group_arn
        weight = var.blue_enabled ? var.blue_weight : 0
      }
      target_group {
        arn    = module.green.target_group_arn
        weight = var.green_enabled ? var.green_weight : 0
      }
      stickiness {
        enabled = false
        # The documentation and the tool disagree about whether duration is optional
        # I'm guessing i'm using an older version of terraform?
        duration = 1
      }
    }
  }

  condition {
    host_header {
      values = [
        "www.planningalerts.org.au",
        "api.planningalerts.org.au"
      ]
    }
  }
}
