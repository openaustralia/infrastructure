variable "planningalerts_org_au_zone_id" {
  default = "a826a2cd0f87d57ef60dc67c5738eec5"
}

# A records

locals {
  # Only include environment if the weight is set to 1. This is a very hacky way of doing something
  # like the weighting on the load balancer for the round robin DNS below
  planningalerts_all_public_ips = concat(
    var.planningalerts_blue_weight == 1 ? module.planningalerts-env-blue.public_ips : [],
    var.planningalerts_green_weight == 1 ? module.planningalerts-env-green.public_ips : []
  )
}

# Round-robin DNS - doing this to avoid having to put in a network load balancer which would cost us money obviously
resource "cloudflare_record" "pa_incoming_email" {
  count   = length(local.planningalerts_all_public_ips)
  zone_id = var.planningalerts_org_au_zone_id
  name    = "incoming.email.planningalerts.org.au"
  type    = "A"
  value   = local.planningalerts_all_public_ips[count.index]
}

# CNAME records

resource "cloudflare_record" "pa_root" {
  zone_id = var.planningalerts_org_au_zone_id
  name    = "planningalerts.org.au"
  type    = "CNAME"
  value   = aws_lb.main.dns_name
}

resource "cloudflare_record" "pa_www" {
  zone_id = var.planningalerts_org_au_zone_id
  name    = "www.planningalerts.org.au"
  type    = "CNAME"
  value   = aws_lb.main.dns_name
}

resource "cloudflare_record" "pa_api" {
  zone_id = var.planningalerts_org_au_zone_id
  name    = "api.planningalerts.org.au"
  type    = "CNAME"
  value   = aws_lb.main.dns_name
}

resource "cloudflare_record" "pa_email" {
  zone_id = var.planningalerts_org_au_zone_id
  name    = "email.planningalerts.org.au"
  type    = "CNAME"
  value   = "cuttlefish.io"
}

resource "cloudflare_record" "pa_email2" {
  zone_id = var.planningalerts_org_au_zone_id
  name    = "email2.planningalerts.org.au"
  type    = "CNAME"
  value   = "cuttlefish.oaf.org.au"
}

# MX records
resource "cloudflare_record" "pa_mx1" {
  zone_id  = var.planningalerts_org_au_zone_id
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 1
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "pa_mx2" {
  zone_id  = var.planningalerts_org_au_zone_id
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 5
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "pa_mx3" {
  zone_id  = var.planningalerts_org_au_zone_id
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 5
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "pa_mx4" {
  zone_id  = var.planningalerts_org_au_zone_id
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "pa_mx5" {
  zone_id  = var.planningalerts_org_au_zone_id
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx3.googlemail.com"
}

# TXT records

resource "cloudflare_record" "pa_spf" {
  zone_id = var.planningalerts_org_au_zone_id
  name    = "planningalerts.org.au"
  type    = "TXT"
  value   = "v=spf1 include:_spf.google.com a:cuttlefish.oaf.org.au  -all"
}

resource "cloudflare_record" "pa_google_site_verification" {
  zone_id = var.planningalerts_org_au_zone_id
  name    = "planningalerts.org.au"
  type    = "TXT"
  value   = "google-site-verification=wZp42fwpmr6aGdCVqp7BJBn_kenD51hYLig7cMOFIBs"
}

resource "cloudflare_record" "pa_facebook_domain_verification" {
  zone_id = var.planningalerts_org_au_zone_id
  name    = "planningalerts.org.au"
  type    = "TXT"
  value   = "facebook-domain-verification=djdz2wywxnas3cxhrch14pfk145g93"
}

# TODO: Remove this once the one below is up and running
resource "cloudflare_record" "pa_domainkey" {
  zone_id = var.planningalerts_org_au_zone_id
  name    = "cuttlefish._domainkey.planningalerts.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoUPCB2huZQkwFnEMn0/jorQ/nHsNul1gQqHbQsX2unANX+dXnnmF0y+rFnB93mlmOVemv+vnQik/DGr+3aCQqOia5t5xXTsbPenmstC1tfCNDl9irQb7sCP8IeiLdcxJ5upsH8PtAod9r7J/Uo8KdXxMPbBFvVT/X9qe25dHkZUqwJHGn7peLmSTe2Ti4ZRTlyolc1orKD7sHx7iI+lU/9Ga1at2kykrXGAs4bUDPY2cmsSMcwqYRu6DQgBz01g9pqaOmDZ7mKwbI7M2m9kX6AWFCb9YqyeyZpW42bytlsKiVsH5bwQmhNFJ/vqTuwyyvBlIDcforixhRGZ13Ufj2QIDAQAB"
}

resource "cloudflare_record" "pa_domainkey2" {
  zone_id = var.planningalerts_org_au_zone_id
  name    = "planningalerts_3.cuttlefish._domainkey.planningalerts.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoUPCB2huZQkwFnEMn0/jorQ/nHsNul1gQqHbQsX2unANX+dXnnmF0y+rFnB93mlmOVemv+vnQik/DGr+3aCQqOia5t5xXTsbPenmstC1tfCNDl9irQb7sCP8IeiLdcxJ5upsH8PtAod9r7J/Uo8KdXxMPbBFvVT/X9qe25dHkZUqwJHGn7peLmSTe2Ti4ZRTlyolc1orKD7sHx7iI+lU/9Ga1at2kykrXGAs4bUDPY2cmsSMcwqYRu6DQgBz01g9pqaOmDZ7mKwbI7M2m9kX6AWFCb9YqyeyZpW42bytlsKiVsH5bwQmhNFJ/vqTuwyyvBlIDcforixhRGZ13Ufj2QIDAQAB"
}

#Front DNS records
resource "cloudflare_record" "oaf_pa_front_mx" {
  zone_id  = var.planningalerts_org_au_zone_id
  name     = "front-mail.planningalerts.org.au"
  type     = "MX"
  priority = 100
  value    = "mx.sendgrid.net"
}

resource "cloudflare_record" "oaf_pa_front_spf" {
  zone_id = var.planningalerts_org_au_zone_id
  name    = "front-mail.planningalerts.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:sendgrid.net ~all"
}

resource "cloudflare_record" "oaf_pa_front_domainkey" {
  zone_id = var.planningalerts_org_au_zone_id
  name    = "m1._domainkey.planningalerts.org.au"
  type    = "TXT"
  value   = "k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4PZZJiwMfMB/CuIZ9yAtNEGzfKzQ7WC7hfGg8UyavtYlDDBgSP6P1AiTBTMzTQbLChvf+Ef5CK46w+RwmgWpL38sxRwjahk45aQxoMOk2FJm7iHnP6zAGUnqAiL8iCdTjn5sp/txNf22bXrx3YS54ePBrfZQxOvkOvE24XZKXXwIDAQAB"
}

# Certification validation data
resource "cloudflare_record" "cert-validation-production" {
  for_each = {
    for dvo in aws_acm_certificate.planningalerts-production.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.planningalerts_org_au_zone_id
  name    = each.value.name
  type    = each.value.type
  value   = trimsuffix(each.value.record, ".")
  ttl     = 60
}
