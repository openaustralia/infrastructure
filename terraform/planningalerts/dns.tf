# A records

locals {
  # Only include environment if the weight is set to 1. This is a very hacky way of doing something
  # like the weighting on the load balancer for the round robin DNS below
  planningalerts_all_public_ips = concat(
    var.blue_weight == 1 ? module.env-blue.public_ips : [],
    var.green_weight == 1 ? module.env-green.public_ips : []
  )
}

# Round-robin DNS - doing this to avoid having to put in a network load balancer which would cost us money obviously
resource "cloudflare_record" "incoming_email" {
  count   = length(local.planningalerts_all_public_ips)
  zone_id = var.zone_id
  name    = "incoming.email.planningalerts.org.au"
  type    = "A"
  value   = local.planningalerts_all_public_ips[count.index]
}

moved {
  from = cloudflare_record.pa_incoming_email
  to   = cloudflare_record.incoming_email
}

# CNAME records

resource "cloudflare_record" "root" {
  zone_id = var.zone_id
  name    = "planningalerts.org.au"
  type    = "CNAME"
  value   = var.load_balancer.dns_name
}

moved {
  from = cloudflare_record.pa_root
  to   = cloudflare_record.root
}

resource "cloudflare_record" "www" {
  zone_id = var.zone_id
  name    = "www.planningalerts.org.au"
  type    = "CNAME"
  value   = var.load_balancer.dns_name
}

moved {
  from = cloudflare_record.pa_www
  to   = cloudflare_record.www
}

resource "cloudflare_record" "api" {
  zone_id = var.zone_id
  name    = "api.planningalerts.org.au"
  type    = "CNAME"
  value   = var.load_balancer.dns_name
}

moved {
  from = cloudflare_record.pa_api
  to   = cloudflare_record.api
}

resource "cloudflare_record" "email" {
  zone_id = var.zone_id
  name    = "email.planningalerts.org.au"
  type    = "CNAME"
  value   = "cuttlefish.io"
}

moved {
  from = cloudflare_record.pa_email
  to   = cloudflare_record.email
}

resource "cloudflare_record" "email2" {
  zone_id = var.zone_id
  name    = "email2.planningalerts.org.au"
  type    = "CNAME"
  value   = "cuttlefish.oaf.org.au"
}

moved {
  from = cloudflare_record.pa_email2
  to   = cloudflare_record.email2
}

resource "cloudflare_record" "donate" {
  zone_id = var.zone_id
  name    = "donate.planningalerts.org.au"
  type    = "CNAME"
  value   = "hosting.raisely.com"
}

moved {
  from = cloudflare_record.pa_donate
  to   = cloudflare_record.donate
}

# MX records
resource "cloudflare_record" "mx1" {
  zone_id  = var.zone_id
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 1
  value    = "aspmx.l.google.com"
}

moved {
  from = cloudflare_record.pa_mx1
  to   = cloudflare_record.mx1
}

resource "cloudflare_record" "mx2" {
  zone_id  = var.zone_id
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 5
  value    = "alt1.aspmx.l.google.com"
}

moved {
  from = cloudflare_record.pa_mx2
  to   = cloudflare_record.mx2
}

resource "cloudflare_record" "mx3" {
  zone_id  = var.zone_id
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 5
  value    = "alt2.aspmx.l.google.com"
}

moved {
  from = cloudflare_record.pa_mx3
  to   = cloudflare_record.mx3
}

resource "cloudflare_record" "mx4" {
  zone_id  = var.zone_id
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx2.googlemail.com"
}

moved {
  from = cloudflare_record.pa_mx4
  to   = cloudflare_record.mx4
}

resource "cloudflare_record" "mx5" {
  zone_id  = var.zone_id
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx3.googlemail.com"
}

moved {
  from = cloudflare_record.pa_mx5
  to   = cloudflare_record.mx5
}

# TXT records

resource "cloudflare_record" "spf" {
  zone_id = var.zone_id
  name    = "planningalerts.org.au"
  type    = "TXT"
  value   = "v=spf1 include:_spf.google.com a:cuttlefish.oaf.org.au  -all"
}

moved {
  from = cloudflare_record.pa_spf
  to   = cloudflare_record.spf
}

resource "cloudflare_record" "google_site_verification" {
  zone_id = var.zone_id
  name    = "planningalerts.org.au"
  type    = "TXT"
  value   = "google-site-verification=wZp42fwpmr6aGdCVqp7BJBn_kenD51hYLig7cMOFIBs"
}

moved {
  from = cloudflare_record.pa_google_site_verification
  to   = cloudflare_record.google_site_verification
}

resource "cloudflare_record" "facebook_domain_verification" {
  zone_id = var.zone_id
  name    = "planningalerts.org.au"
  type    = "TXT"
  value   = "facebook-domain-verification=djdz2wywxnas3cxhrch14pfk145g93"
}

moved {
  from = cloudflare_record.pa_facebook_domain_verification
  to   = cloudflare_record.facebook_domain_verification
}

# TODO: Remove this once the one below is up and running
resource "cloudflare_record" "domainkey" {
  zone_id = var.zone_id
  name    = "cuttlefish._domainkey.planningalerts.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoUPCB2huZQkwFnEMn0/jorQ/nHsNul1gQqHbQsX2unANX+dXnnmF0y+rFnB93mlmOVemv+vnQik/DGr+3aCQqOia5t5xXTsbPenmstC1tfCNDl9irQb7sCP8IeiLdcxJ5upsH8PtAod9r7J/Uo8KdXxMPbBFvVT/X9qe25dHkZUqwJHGn7peLmSTe2Ti4ZRTlyolc1orKD7sHx7iI+lU/9Ga1at2kykrXGAs4bUDPY2cmsSMcwqYRu6DQgBz01g9pqaOmDZ7mKwbI7M2m9kX6AWFCb9YqyeyZpW42bytlsKiVsH5bwQmhNFJ/vqTuwyyvBlIDcforixhRGZ13Ufj2QIDAQAB"
}

moved {
  from = cloudflare_record.pa_domainkey
  to   = cloudflare_record.domainkey
}

resource "cloudflare_record" "domainkey2" {
  zone_id = var.zone_id
  name    = "planningalerts_3.cuttlefish._domainkey.planningalerts.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoUPCB2huZQkwFnEMn0/jorQ/nHsNul1gQqHbQsX2unANX+dXnnmF0y+rFnB93mlmOVemv+vnQik/DGr+3aCQqOia5t5xXTsbPenmstC1tfCNDl9irQb7sCP8IeiLdcxJ5upsH8PtAod9r7J/Uo8KdXxMPbBFvVT/X9qe25dHkZUqwJHGn7peLmSTe2Ti4ZRTlyolc1orKD7sHx7iI+lU/9Ga1at2kykrXGAs4bUDPY2cmsSMcwqYRu6DQgBz01g9pqaOmDZ7mKwbI7M2m9kX6AWFCb9YqyeyZpW42bytlsKiVsH5bwQmhNFJ/vqTuwyyvBlIDcforixhRGZ13Ufj2QIDAQAB"
}

moved {
  from = cloudflare_record.pa_domainkey2
  to   = cloudflare_record.domainkey2
}

resource "cloudflare_record" "domainkey_google" {
  zone_id = var.zone_id
  name    = "google._domainkey.planningalerts.org.au"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkUq+EPS6XemyHdVi5CCW7+M+X1XMrAg85Y2oYEUYVcB2IU+1HF/fGUdY9w8wvphSC/28wznJOOTl92pj6/DvwRcfpogRrjITYmPZQMOC0SQ4/4nOeL5ug6fNWFg74LZQvQJqWGAQuUhiSiwxUpkUHAv6H5iE/EKDVOdeWjPWjsIkoAC5HdAie0WCcq3gDlfDJZ3L6K7/nGorPd96764EYG/pdsN43/jzcU23vVGJlhw9my1jvkxNnMS1xRkUuk/JcCIRWp4RkgQOkK7JEoNXB2u+bgW+8mLlGX66dag2l67CR+qzOuE1nHcOu5ADLqVh42MOTNMhw75TzugEbtn0QQIDAQAB"
}

moved {
  from = cloudflare_record.pa_domainkey_google
  to   = cloudflare_record.domainkey_google
}

# Certification validation data
resource "cloudflare_record" "cert-validation-production" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  value   = trimsuffix(each.value.record, ".")
  ttl     = 60
}

# For the time being we're just using DMARC records to get some data on what's
# happening with email that we're sending (and whether anyone else is impersonating
# us).
# We're using a free service provided by https://dmarc.postmarkapp.com/
# This generates a weekly DMARC report which gets sent by email on Monday mornings
# Report goes to contact@oaf.org.au
resource "cloudflare_record" "dmarc" {
  zone_id = var.zone_id
  name    = "_dmarc.planningalerts.org.au"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+b1g0fn6boqu@dmarc.postmarkapp.com; sp=none; aspf=r;"
}

moved {
  from = cloudflare_record.pa_dmarc
  to   = cloudflare_record.dmarc
}
