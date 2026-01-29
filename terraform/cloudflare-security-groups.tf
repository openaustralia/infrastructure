# =============================================================================
# Cloudflare IP Restrictions for Security Groups
# IPs are fetched dynamically from Cloudflare's official endpoints.
# The Ansible oaf.cloudflare role uses the same endpoints for nginx real_ip config.
# =============================================================================

data "http" "cloudflare_ipv4" {
  url = "https://www.cloudflare.com/ips-v4"
}

data "http" "cloudflare_ipv6" {
  url = "https://www.cloudflare.com/ips-v6"
}

locals {
  cloudflare_ipv4_cidrs = compact(split("\n", trimspace(data.http.cloudflare_ipv4.response_body)))
  cloudflare_ipv6_cidrs = compact(split("\n", trimspace(data.http.cloudflare_ipv6.response_body)))
}

# =============================================================================
# theyvoteforyou - Cloudflare Rules
# =============================================================================

resource "aws_security_group_rule" "theyvoteforyou_http_cloudflare_ipv4" {
  count             = var.theyvoteforyou_cloudflare_only ? length(local.cloudflare_ipv4_cidrs) : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [local.cloudflare_ipv4_cidrs[count.index]]
  security_group_id = aws_security_group.theyvoteforyou.id
  description       = "HTTP from Cloudflare"
}

resource "aws_security_group_rule" "theyvoteforyou_https_cloudflare_ipv4" {
  count             = var.theyvoteforyou_cloudflare_only ? length(local.cloudflare_ipv4_cidrs) : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [local.cloudflare_ipv4_cidrs[count.index]]
  security_group_id = aws_security_group.theyvoteforyou.id
  description       = "HTTPS from Cloudflare"
}

resource "aws_security_group_rule" "theyvoteforyou_http_cloudflare_ipv6" {
  count             = var.theyvoteforyou_cloudflare_only ? length(local.cloudflare_ipv6_cidrs) : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  ipv6_cidr_blocks  = [local.cloudflare_ipv6_cidrs[count.index]]
  security_group_id = aws_security_group.theyvoteforyou.id
  description       = "HTTP from Cloudflare IPv6"
}

resource "aws_security_group_rule" "theyvoteforyou_https_cloudflare_ipv6" {
  count             = var.theyvoteforyou_cloudflare_only ? length(local.cloudflare_ipv6_cidrs) : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  ipv6_cidr_blocks  = [local.cloudflare_ipv6_cidrs[count.index]]
  security_group_id = aws_security_group.theyvoteforyou.id
  description       = "HTTPS from Cloudflare IPv6"
}

# =============================================================================
# righttoknow - Cloudflare Rules
# =============================================================================

resource "aws_security_group_rule" "righttoknow_http_cloudflare_ipv4" {
  count             = var.righttoknow_cloudflare_only ? length(local.cloudflare_ipv4_cidrs) : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [local.cloudflare_ipv4_cidrs[count.index]]
  security_group_id = aws_security_group.righttoknow.id
  description       = "HTTP from Cloudflare"
}

resource "aws_security_group_rule" "righttoknow_https_cloudflare_ipv4" {
  count             = var.righttoknow_cloudflare_only ? length(local.cloudflare_ipv4_cidrs) : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [local.cloudflare_ipv4_cidrs[count.index]]
  security_group_id = aws_security_group.righttoknow.id
  description       = "HTTPS from Cloudflare"
}

resource "aws_security_group_rule" "righttoknow_http_cloudflare_ipv6" {
  count             = var.righttoknow_cloudflare_only ? length(local.cloudflare_ipv6_cidrs) : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  ipv6_cidr_blocks  = [local.cloudflare_ipv6_cidrs[count.index]]
  security_group_id = aws_security_group.righttoknow.id
  description       = "HTTP from Cloudflare IPv6"
}

resource "aws_security_group_rule" "righttoknow_https_cloudflare_ipv6" {
  count             = var.righttoknow_cloudflare_only ? length(local.cloudflare_ipv6_cidrs) : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  ipv6_cidr_blocks  = [local.cloudflare_ipv6_cidrs[count.index]]
  security_group_id = aws_security_group.righttoknow.id
  description       = "HTTPS from Cloudflare IPv6"
}

# =============================================================================
# openaustralia - Cloudflare Rules
# =============================================================================

resource "aws_security_group_rule" "openaustralia_http_cloudflare_ipv4" {
  count             = var.openaustralia_cloudflare_only ? length(local.cloudflare_ipv4_cidrs) : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [local.cloudflare_ipv4_cidrs[count.index]]
  security_group_id = aws_security_group.openaustralia.id
  description       = "HTTP from Cloudflare"
}

resource "aws_security_group_rule" "openaustralia_https_cloudflare_ipv4" {
  count             = var.openaustralia_cloudflare_only ? length(local.cloudflare_ipv4_cidrs) : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [local.cloudflare_ipv4_cidrs[count.index]]
  security_group_id = aws_security_group.openaustralia.id
  description       = "HTTPS from Cloudflare"
}

resource "aws_security_group_rule" "openaustralia_http_cloudflare_ipv6" {
  count             = var.openaustralia_cloudflare_only ? length(local.cloudflare_ipv6_cidrs) : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  ipv6_cidr_blocks  = [local.cloudflare_ipv6_cidrs[count.index]]
  security_group_id = aws_security_group.openaustralia.id
  description       = "HTTP from Cloudflare IPv6"
}

resource "aws_security_group_rule" "openaustralia_https_cloudflare_ipv6" {
  count             = var.openaustralia_cloudflare_only ? length(local.cloudflare_ipv6_cidrs) : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  ipv6_cidr_blocks  = [local.cloudflare_ipv6_cidrs[count.index]]
  security_group_id = aws_security_group.openaustralia.id
  description       = "HTTPS from Cloudflare IPv6"
}

# =============================================================================
# opengovernment - Cloudflare Rules
# =============================================================================

resource "aws_security_group_rule" "opengovernment_http_cloudflare_ipv4" {
  count             = var.opengovernment_cloudflare_only ? length(local.cloudflare_ipv4_cidrs) : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [local.cloudflare_ipv4_cidrs[count.index]]
  security_group_id = aws_security_group.opengovernment.id
  description       = "HTTP from Cloudflare"
}

resource "aws_security_group_rule" "opengovernment_https_cloudflare_ipv4" {
  count             = var.opengovernment_cloudflare_only ? length(local.cloudflare_ipv4_cidrs) : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [local.cloudflare_ipv4_cidrs[count.index]]
  security_group_id = aws_security_group.opengovernment.id
  description       = "HTTPS from Cloudflare"
}

resource "aws_security_group_rule" "opengovernment_http_cloudflare_ipv6" {
  count             = var.opengovernment_cloudflare_only ? length(local.cloudflare_ipv6_cidrs) : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  ipv6_cidr_blocks  = [local.cloudflare_ipv6_cidrs[count.index]]
  security_group_id = aws_security_group.opengovernment.id
  description       = "HTTP from Cloudflare IPv6"
}

resource "aws_security_group_rule" "opengovernment_https_cloudflare_ipv6" {
  count             = var.opengovernment_cloudflare_only ? length(local.cloudflare_ipv6_cidrs) : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  ipv6_cidr_blocks  = [local.cloudflare_ipv6_cidrs[count.index]]
  security_group_id = aws_security_group.opengovernment.id
  description       = "HTTPS from Cloudflare IPv6"
}

# =============================================================================
# planningalerts (load balancer) - Cloudflare Rules
# =============================================================================

resource "aws_security_group_rule" "planningalerts_http_cloudflare_ipv4" {
  count             = var.planningalerts_cloudflare_only ? length(local.cloudflare_ipv4_cidrs) : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [local.cloudflare_ipv4_cidrs[count.index]]
  security_group_id = aws_security_group.load-balancer.id
  description       = "HTTP from Cloudflare"
}

resource "aws_security_group_rule" "planningalerts_https_cloudflare_ipv4" {
  count             = var.planningalerts_cloudflare_only ? length(local.cloudflare_ipv4_cidrs) : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [local.cloudflare_ipv4_cidrs[count.index]]
  security_group_id = aws_security_group.load-balancer.id
  description       = "HTTPS from Cloudflare"
}

resource "aws_security_group_rule" "planningalerts_http_cloudflare_ipv6" {
  count             = var.planningalerts_cloudflare_only ? length(local.cloudflare_ipv6_cidrs) : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  ipv6_cidr_blocks  = [local.cloudflare_ipv6_cidrs[count.index]]
  security_group_id = aws_security_group.load-balancer.id
  description       = "HTTP from Cloudflare IPv6"
}

resource "aws_security_group_rule" "planningalerts_https_cloudflare_ipv6" {
  count             = var.planningalerts_cloudflare_only ? length(local.cloudflare_ipv6_cidrs) : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  ipv6_cidr_blocks  = [local.cloudflare_ipv6_cidrs[count.index]]
  security_group_id = aws_security_group.load-balancer.id
  description       = "HTTPS from Cloudflare IPv6"
}
