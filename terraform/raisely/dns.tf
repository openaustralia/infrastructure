terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4.0"
    }
  }
}

# CNAME records
resource "cloudflare_record" "root" {
  zone_id = var.zone_id
  name    = "donate.oaf.org.au"
  type    = "CNAME"
  value   = "hosting.raisely.com"
}

moved {
  from = cloudflare_record.oaf_donate
  to   = cloudflare_record.root
}

resource "cloudflare_record" "email" {
  zone_id = var.zone_id
  name    = "email.donate.oaf.org.au"
  type    = "CNAME"
  value   = "mailgun.org"
}

moved {
  from = cloudflare_record.oaf_donate_email
  to   = cloudflare_record.email
}

# TXT records
resource "cloudflare_record" "domainkey" {
  zone_id = var.zone_id
  name    = "k1._domainkey.donate.oaf.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDnev2b0yPZEURaroYsZdtm8NbxF5lHvKUQZwnko8ShVSjJIEbQdFORyYAA0f+lcDOIAXl0eKSw2vv3ThCRet0cxqCCLXPVmmqNvEvGyezXXmuiZVJwge4gcZSB1UhwScfS+6qN0KlkBIwxgQwI1XH1ib4Q61+3rffCHJrUJ9bD7QIDAQAB"
}

moved {
  from = cloudflare_record.oaf_donate_domainkey
  to   = cloudflare_record.domainkey
}

resource "cloudflare_record" "spf" {
  zone_id = var.zone_id
  name    = "donate.oaf.org.au"
  type    = "TXT"
  value   = "v=spf1 include:raiselysite.com ~all"
}

moved {
  from = cloudflare_record.oaf_donate_spf
  to   = cloudflare_record.spf
}

# MX records
resource "cloudflare_record" "mx1" {
  zone_id = var.zone_id
  name    = "donate.oaf.org.au"
  type    = "MX"
  value   = "mxa.mailgun.org"
}

moved {
  from = cloudflare_record.oaf_donate_mxa
  to   = cloudflare_record.mx1
}

resource "cloudflare_record" "mx2" {
  zone_id = var.zone_id
  name    = "donate.oaf.org.au"
  type    = "MX"
  value   = "mxb.mailgun.org"
}

moved {
  from = cloudflare_record.oaf_donate_mxb
  to   = cloudflare_record.mx2
}
