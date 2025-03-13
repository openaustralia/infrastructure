
## oaf.org.au
# A records
resource "cloudflare_record" "root" {
  zone_id = var.oaf_org_au_zone_id
  name    = "oaf.org.au"
  type    = "A"
  value   = aws_eip.main.public_ip
}

# CNAME records
resource "cloudflare_record" "test" {
  zone_id = var.oaf_org_au_zone_id
  name    = "test.oaf.org.au"
  type    = "CNAME"
  value   = "oaf.org.au"
}

resource "cloudflare_record" "www" {
  zone_id = var.oaf_org_au_zone_id
  name    = "www.oaf.org.au"
  type    = "CNAME"
  value   = "oaf.org.au"
}

# MX records

# We can now use a single MX record for Google workspace
resource "cloudflare_record" "mx" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "oaf.org.au"
  type     = "MX"
  priority = 1
  value    = "smtp.google.com"
}

# TXT records
resource "cloudflare_record" "spf" {
  zone_id = var.oaf_org_au_zone_id
  name    = "oaf.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:_spf.google.com ~all"
}

resource "cloudflare_record" "google_site_verification" {
  zone_id = var.oaf_org_au_zone_id
  name    = "oaf.org.au"
  type    = "TXT"
  value   = "google-site-verification=RLhe_zgIDJMxpFFYFewv0KaRlWQvH-JDBxxpEV-8noY"
}

resource "cloudflare_record" "facebook_domain_verification" {
  zone_id = var.oaf_org_au_zone_id
  name    = "oaf.org.au"
  type    = "TXT"
  value   = "facebook-domain-verification=hfy8rxjyjsmjynz68xr373fy86lg4o"
}

resource "cloudflare_record" "bluesky_domain_verification" {
  zone_id = var.oaf_org_au_zone_id
  name    = "_atproto.oaf.org.au"
  type    = "TXT"
  value   = "did=did:plc:go25mxaixuu35qmmpx42zltv"
}

resource "cloudflare_record" "github_challenge" {
  zone_id = var.oaf_org_au_zone_id
  name    = "_github-challenge-openaustralia.www.oaf.org.au"
  type    = "TXT"
  value   = "6c5d1d8cf8"
}

resource "cloudflare_record" "github_challenge2" {
  zone_id = var.oaf_org_au_zone_id
  name    = "_github-challenge-openaustralia.oaf.org.au"
  type    = "TXT"
  value   = "209f2b7179"
}

resource "cloudflare_record" "domainkey_google" {
  zone_id = var.oaf_org_au_zone_id
  name    = "google._domainkey.oaf.org.au"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvlrS/9YendfJ0TnN9iBW67qaWDOyaNKDqeruhNBQZYqCNWSodX+tn7octjR2Xs4VJE5Ex8noA8LTqILBGQHyPDAk0FUg9BS3jaQyfwdUqiZmDqfQlc07urXLHbdttnpBNNh21Mut/RHohHMJa7b1cTXGwU//FBiJNXf4fy+XaS7/TBi0ydTvajdE6/3RnQn/0TthC3AvxQoqom0P1nEVB4RFbDNkud0/ajISwi9Gz+JEH/jiScq5D1rWWWG6ALkfTVuYxazpAAdKU4c7OsKRbE1zp4BKXpHWzx2nWVy5pmIR2ohi3yIuFEYl24LhIstH3hOBw2zF+j1HvWATDmJ9aQIDAQAB"
}

resource "cloudflare_record" "domainkey_cuttlefish" {
  zone_id = var.oaf_org_au_zone_id
  # This is named badly. It is in fact used by all of wordpress on oaf.org.au to send email
  name  = "civicrm_37.cuttlefish._domainkey.oaf.org.au"
  type  = "TXT"
  value = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7fLXgEr26+qIswukULxl1OIPfz2CZ1iPcy4+LsveWZKGi1mU4jcy2vregS8FOm1B/V2nI354jBxlEi4XLxElcThq7zrFcDLXPNkrCg7yyPCF3qBnISlWDF/EwB0wOE1VF3QcwcILdR9vzRHP2yo0uTkz+stZpzVgthfM4FAOd5vDQ+cYxCwKTtXyCBUHH+/c2KUYnKiAOEXmuOUfwdo7uAPdClyg8mPAqYzjEQtPlktulD3rLQp3bom5lkGVLzklfiD77JVK1PD1a9C2OItG55KYbie3EPrXLkecGMob1ulhvz7ml/bSx3bqDUcbelnVLlT9VjeRiEUWoSYzJxXoMwIDAQAB"
}

# For the time being we're just using DMARC records to get some data on what's
# happening with email that we're sending (and whether anyone else is impersonating
# us).
# We're using a free service provided by https://dmarc.postmarkapp.com/
# This generates a weekly DMARC report which gets sent by email on Monday mornings
# Report goes to webmaster@oaf.org.au
resource "cloudflare_record" "dmarc" {
  zone_id = var.oaf_org_au_zone_id
  name    = "_dmarc.oaf.org.au"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+ff2eamlrqpn@dmarc.postmarkapp.com; sp=none; aspf=r;"
}

## openaustraliafoundation.org.au

# A records

resource "cloudflare_record" "alt_root" {
  zone_id = var.openaustraliafoundation_org_au_zone_id
  name    = "openaustraliafoundation.org.au"
  type    = "A"
  value   = aws_eip.main.public_ip
}

# CNAME records
resource "cloudflare_record" "alt_www" {
  zone_id = var.openaustraliafoundation_org_au_zone_id
  name    = "www.openaustraliafoundation.org.au"
  type    = "CNAME"
  value   = "openaustraliafoundation.org.au"
}

resource "cloudflare_record" "alt_test" {
  zone_id = var.openaustraliafoundation_org_au_zone_id
  name    = "test.openaustraliafoundation.org.au"
  type    = "CNAME"
  value   = "openaustraliafoundation.org.au"
}

# MX records

# We can now use a single MX record for Google workspace
resource "cloudflare_record" "alt_mx" {
  zone_id  = var.openaustraliafoundation_org_au_zone_id
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 1
  value    = "smtp.google.com"
}

# TXT records
resource "cloudflare_record" "alt_spf" {
  zone_id = var.openaustraliafoundation_org_au_zone_id
  name    = "openaustraliafoundation.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:_spf.google.com ~all"
}

resource "cloudflare_record" "alt_google_site_verification" {
  zone_id = var.openaustraliafoundation_org_au_zone_id
  name    = "openaustraliafoundation.org.au"
  type    = "TXT"
  value   = "google-site-verification=sNfu9GJBQDlBYvdsXm8b61JjxxPfDy2JH9ok2UKHu48"
}

resource "cloudflare_record" "alt_domainkey_google" {
  zone_id = var.openaustraliafoundation_org_au_zone_id
  name    = "google._domainkey.openaustraliafoundation.org.au"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAz6aQEaWYi4O0qYTauYZhhABGd+ZkC2vnWS5soLS0cjW4Q/W75fYyBULC65HdCcTjbLVGuPh2tmFxjwoW20Vlh/qpqsWeBYIo20KSKgRFAPqFwbCXuumEcDoGcjKm7O9uTAO+cLe1wkT2XtpAA+Vk1pTSismJvt93YXUaX6lZuIaO5BO9d221ax5N/YJnZ29EIYzXUtStojC6QxkQ506XB4Y1s6SaNr+UJHBtLTJl/ffqwcCqL6DyxkrYKDoKxWxj1fO8aNrPSE2xQYbgCYIcOYOOUZmwyuY/4ILKjlOdJfz0OLcn1/2sbCLO8oTeXZe/ftt2xsMCEAkO+ROc67BFeQIDAQAB"
}

# For the time being we're just using DMARC records to get some data on what's
# happening with email that we're sending (and whether anyone else is impersonating
# us).
# We're using a free service provided by https://dmarc.postmarkapp.com/
# This generates a weekly DMARC report which gets sent by email on Monday mornings
# Report goes to webmaster@openaustraliafoundation.org.au
resource "cloudflare_record" "alt_dmarc" {
  zone_id = var.openaustraliafoundation_org_au_zone_id
  name    = "_dmarc.openaustraliafoundation.org.au"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+tziobvarown@dmarc.postmarkapp.com; sp=none; aspf=r;"
}
