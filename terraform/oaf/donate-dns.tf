# CNAME records
resource "cloudflare_record" "oaf_donate" {
  zone_id = var.oaf_org_au_zone_id
  name    = "donate.oaf.org.au"
  type    = "CNAME"
  value   = "hosting.raisely.com"
}

resource "cloudflare_record" "oaf_donate_email" {
  zone_id = var.oaf_org_au_zone_id
  name    = "email.donate.oaf.org.au"
  type    = "CNAME"
  value   = "mailgun.org"
}

# TXT records
resource "cloudflare_record" "oaf_donate_domainkey" {
  zone_id = var.oaf_org_au_zone_id
  name    = "k1._domainkey.donate.oaf.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDnev2b0yPZEURaroYsZdtm8NbxF5lHvKUQZwnko8ShVSjJIEbQdFORyYAA0f+lcDOIAXl0eKSw2vv3ThCRet0cxqCCLXPVmmqNvEvGyezXXmuiZVJwge4gcZSB1UhwScfS+6qN0KlkBIwxgQwI1XH1ib4Q61+3rffCHJrUJ9bD7QIDAQAB"
}

resource "cloudflare_record" "oaf_donate_spf" {
  zone_id = var.oaf_org_au_zone_id
  name    = "donate.oaf.org.au"
  type    = "TXT"
  value   = "v=spf1 include:raiselysite.com ~all"
}

# MX records
resource "cloudflare_record" "oaf_donate_mxa" {
  zone_id = var.oaf_org_au_zone_id
  name    = "donate.oaf.org.au"
  type    = "MX"
  value   = "mxa.mailgun.org"
}

resource "cloudflare_record" "oaf_donate_mxb" {
  zone_id = var.oaf_org_au_zone_id
  name    = "donate.oaf.org.au"
  type    = "MX"
  value   = "mxb.mailgun.org"
}
