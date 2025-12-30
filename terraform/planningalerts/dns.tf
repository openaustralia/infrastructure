resource "cloudflare_zone" "main" {
  account_id = var.cloudflare_account_id
  plan       = "business"
  zone       = "planningalerts.org.au"
}

# A records

locals {
  # Only include environment if the weight is set to 1. This is a very hacky way of doing something
  # like the weighting on the load balancer for the round robin DNS below
  planningalerts_all_public_ips = concat(
    var.blue_weight == 1 ? module.blue.public_ips : [],
    var.green_weight == 1 ? module.green.public_ips : []
  )
}

# Round-robin DNS - doing this to avoid having to put in a network load balancer which would cost us money obviously
resource "cloudflare_record" "incoming_email" {
  count   = length(local.planningalerts_all_public_ips)
  zone_id = cloudflare_zone.main.id
  name    = "incoming.email.planningalerts.org.au"
  type    = "A"
  value   = local.planningalerts_all_public_ips[count.index]
}

# CNAME records

resource "cloudflare_record" "root" {
  zone_id = cloudflare_zone.main.id
  name    = "planningalerts.org.au"
  type    = "CNAME"
  value   = var.load_balancer.dns_name
  proxied = false
}

resource "cloudflare_record" "www" {
  zone_id = cloudflare_zone.main.id
  name    = "www.planningalerts.org.au"
  type    = "CNAME"
  value   = var.load_balancer.dns_name
  proxied = false
}

resource "cloudflare_record" "api" {
  zone_id = cloudflare_zone.main.id
  name    = "api.planningalerts.org.au"
  type    = "CNAME"
  value   = var.load_balancer.dns_name
  proxied = false
}

resource "cloudflare_record" "email2" {
  zone_id = cloudflare_zone.main.id
  name    = "email2.planningalerts.org.au"
  type    = "CNAME"
  value   = "cuttlefish.oaf.org.au"
}

resource "cloudflare_record" "donate" {
  zone_id = cloudflare_zone.main.id
  name    = "donate.planningalerts.org.au"
  type    = "CNAME"
  value   = "hosting.raisely.com"
}

# MX records

# We can now use a single MX record for Google workspace
resource "cloudflare_record" "mx" {
  zone_id  = cloudflare_zone.main.id
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 1
  value    = "smtp.google.com"
}

# TXT records

resource "cloudflare_record" "spf" {
  zone_id = cloudflare_zone.main.id
  name    = "planningalerts.org.au"
  type    = "TXT"
  value   = "v=spf1 include:_spf.google.com a:cuttlefish.oaf.org.au  -all"
}

resource "cloudflare_record" "google_site_verification" {
  zone_id = cloudflare_zone.main.id
  name    = "planningalerts.org.au"
  type    = "TXT"
  value   = "google-site-verification=wZp42fwpmr6aGdCVqp7BJBn_kenD51hYLig7cMOFIBs"
}

resource "cloudflare_record" "facebook_domain_verification" {
  zone_id = cloudflare_zone.main.id
  name    = "planningalerts.org.au"
  type    = "TXT"
  value   = "facebook-domain-verification=djdz2wywxnas3cxhrch14pfk145g93"
}

resource "cloudflare_record" "yahoo_domain_verification" {
  zone_id = cloudflare_zone.main.id
  name    = "planningalerts.org.au"
  type    = "TXT"
  value   = "yahoo-verification-key=j/JGsx5QsyhsESucFAGKelmOmW80kCYKW5lxhkxvzr4="
}


resource "cloudflare_record" "domainkey" {
  zone_id = cloudflare_zone.main.id
  name    = "planningalerts_3.cuttlefish._domainkey.planningalerts.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoUPCB2huZQkwFnEMn0/jorQ/nHsNul1gQqHbQsX2unANX+dXnnmF0y+rFnB93mlmOVemv+vnQik/DGr+3aCQqOia5t5xXTsbPenmstC1tfCNDl9irQb7sCP8IeiLdcxJ5upsH8PtAod9r7J/Uo8KdXxMPbBFvVT/X9qe25dHkZUqwJHGn7peLmSTe2Ti4ZRTlyolc1orKD7sHx7iI+lU/9Ga1at2kykrXGAs4bUDPY2cmsSMcwqYRu6DQgBz01g9pqaOmDZ7mKwbI7M2m9kX6AWFCb9YqyeyZpW42bytlsKiVsH5bwQmhNFJ/vqTuwyyvBlIDcforixhRGZ13Ufj2QIDAQAB"
}

resource "cloudflare_record" "domainkey_google" {
  zone_id = cloudflare_zone.main.id
  name    = "google._domainkey.planningalerts.org.au"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkUq+EPS6XemyHdVi5CCW7+M+X1XMrAg85Y2oYEUYVcB2IU+1HF/fGUdY9w8wvphSC/28wznJOOTl92pj6/DvwRcfpogRrjITYmPZQMOC0SQ4/4nOeL5ug6fNWFg74LZQvQJqWGAQuUhiSiwxUpkUHAv6H5iE/EKDVOdeWjPWjsIkoAC5HdAie0WCcq3gDlfDJZ3L6K7/nGorPd96764EYG/pdsN43/jzcU23vVGJlhw9my1jvkxNnMS1xRkUuk/JcCIRWp4RkgQOkK7JEoNXB2u+bgW+8mLlGX66dag2l67CR+qzOuE1nHcOu5ADLqVh42MOTNMhw75TzugEbtn0QQIDAQAB"
}

# For the time being we're just using DMARC records to get some data on what's
# happening with email that we're sending (and whether anyone else is impersonating
# us).
# We're using a free service provided by https://dmarc.postmarkapp.com/
# This generates a weekly DMARC report which gets sent by email on Monday mornings
# Report goes to contact@oaf.org.au
resource "cloudflare_record" "dmarc" {
  zone_id = cloudflare_zone.main.id
  name    = "_dmarc.planningalerts.org.au"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+b1g0fn6boqu@dmarc.postmarkapp.com; sp=none; aspf=r;"
}
