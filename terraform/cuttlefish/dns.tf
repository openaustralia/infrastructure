# A records

resource "cloudflare_record" "a" {
  zone_id = var.oaf_org_au_zone_id
  name    = "cuttlefish.oaf.org.au"
  type    = "A"
  value   = var.cuttlefish_ipv4
}

# AAAA records
resource "cloudflare_record" "aaaa" {
  zone_id = var.oaf_org_au_zone_id
  name    = "cuttlefish.oaf.org.au"
  type    = "AAAA"
  value   = var.cuttlefish_ipv6
}

# MX records

resource "cloudflare_record" "mx1" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 1
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "mx2" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 5
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "mx3" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 5
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "mx4" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "mx5" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx3.googlemail.com"
}

# TXT records

resource "cloudflare_record" "spf" {
  zone_id = var.oaf_org_au_zone_id
  name    = "cuttlefish.oaf.org.au"
  type    = "TXT"
  value   = "v=spf1 include:_spf.google.com ip4:${var.cuttlefish_ipv4} ip6:${var.cuttlefish_ipv6} -all"
}

resource "cloudflare_record" "cuttlefish_domainkey_cuttlefish" {
  zone_id = var.oaf_org_au_zone_id
  name    = "cuttlefish._domainkey.cuttlefish.oaf.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvEPfY69ZLYEn+I8rXaRLpTTb9c8AAEdjlUIPAX5nZ2cPYRxA8eCO/AYgXGXXdvGYWUm7sDkil6oSlqZjLx3au31AOoPNimi8FT2QjSgDp/Qkd403ACW314Aio4lo39y+un4GK0ih6KDuJAcxSftoGd9DFViBkVUs8Cs/WhFnc2dkhKTpCtt8Mji+bNtTOYsFwAg8LC3tDnWg+V3UTqqFQBi476DemGPVjxtpe48uFjCQpGg8T0uW54cIKWiC3PWCU0Ksj3HVMhE8P33McW/VFyGAx+nDlc0i6VY3zZi2i86O9Z84j0bJm/607lFK/pCa/Rv8hSJz5Ksk2EkD0NKh0QIDAQAB"
}

resource "cloudflare_record" "google_domainkey_cuttlefish" {
  zone_id = var.oaf_org_au_zone_id
  name    = "google._domainkey.cuttlefish.oaf.org.au"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuUiS9SxKN53lUy+8ICaOSTLcK+RyewOTxZRG9Om4+W6WV34DXhGUK9c98cf0J9DtfPxmBgHwxqVoL/4T+mRoxH3Hdjdyi35/r9sb/0hXGiEOM/MVBJJwr8MqxLH4UK+d04bYHG/M/2lAVw0sEq4FHUJDo9PCsz+ZSnKqsoRiOhHaeTZsEp6yaBUKQJsF06y3EGk4TBB8weiDw7TNNxO/16QOu/wNErWuLXjxlQw6iSjDxCcC05ub8sv1VUzdj6hLmOBFVAvoNmBuWOtc0ri7sqZyb09Atmpfqnb0rQWUqET7Nvh9918KXNOGlws2qHQ8Pdf9uME6swYIrkFpsS0yWQIDAQAB"
}

# TODO: Remove this once the one below is up and running
resource "cloudflare_record" "cuttlefish_domainkey_oaf" {
  zone_id = var.oaf_org_au_zone_id
  name    = "cuttlefish._domainkey.oaf.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7fLXgEr26+qIswukULxl1OIPfz2CZ1iPcy4+LsveWZKGi1mU4jcy2vregS8FOm1B/V2nI354jBxlEi4XLxElcThq7zrFcDLXPNkrCg7yyPCF3qBnISlWDF/EwB0wOE1VF3QcwcILdR9vzRHP2yo0uTkz+stZpzVgthfM4FAOd5vDQ+cYxCwKTtXyCBUHH+/c2KUYnKiAOEXmuOUfwdo7uAPdClyg8mPAqYzjEQtPlktulD3rLQp3bom5lkGVLzklfiD77JVK1PD1a9C2OItG55KYbie3EPrXLkecGMob1ulhvz7ml/bSx3bqDUcbelnVLlT9VjeRiEUWoSYzJxXoMwIDAQAB"
}

# TODO: Double check that we can remove this as we're no longer using civicrm
resource "cloudflare_record" "oaf_domainkey2" {
  zone_id = var.oaf_org_au_zone_id
  name    = "civicrm_37.cuttlefish._domainkey.oaf.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7fLXgEr26+qIswukULxl1OIPfz2CZ1iPcy4+LsveWZKGi1mU4jcy2vregS8FOm1B/V2nI354jBxlEi4XLxElcThq7zrFcDLXPNkrCg7yyPCF3qBnISlWDF/EwB0wOE1VF3QcwcILdR9vzRHP2yo0uTkz+stZpzVgthfM4FAOd5vDQ+cYxCwKTtXyCBUHH+/c2KUYnKiAOEXmuOUfwdo7uAPdClyg8mPAqYzjEQtPlktulD3rLQp3bom5lkGVLzklfiD77JVK1PD1a9C2OItG55KYbie3EPrXLkecGMob1ulhvz7ml/bSx3bqDUcbelnVLlT9VjeRiEUWoSYzJxXoMwIDAQAB"
}

moved {
  from = cloudflare_record.oaf_cuttlefish
  to   = cloudflare_record.a
}

moved {
  from = cloudflare_record.oaf_aaaa_cuttlefish
  to   = cloudflare_record.aaaa
}

moved {
  from = cloudflare_record.oaf_cuttlefish_mx1
  to   = cloudflare_record.mx1
}

moved {
  from = cloudflare_record.oaf_cuttlefish_mx2
  to   = cloudflare_record.mx2
}

moved {
  from = cloudflare_record.oaf_cuttlefish_mx3
  to   = cloudflare_record.mx3
}

moved {
  from = cloudflare_record.oaf_cuttlefish_mx4
  to   = cloudflare_record.mx4
}

moved {
  from = cloudflare_record.oaf_cuttlefish_mx5
  to   = cloudflare_record.mx5
}

moved {
  from = cloudflare_record.oaf_cuttlefish_spf
  to   = cloudflare_record.spf
}

moved {
  from = cloudflare_record.oaf_cuttlefish_domainkey
  to   = cloudflare_record.cuttlefish_domainkey_cuttlefish
}

moved {
  from = cloudflare_record.oaf_cuttlefish_google_domainkey
  to   = cloudflare_record.google_domainkey_cuttlefish
}

moved {
  from = cloudflare_record.oaf_domainkey
  to   = cloudflare_record.cuttlefish_domainkey_oaf
}

