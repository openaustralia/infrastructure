variable "oaf_org_au_zone_id" {
  default = "9289b2adebd1dac52cb9e6f8344a56da"
}

variable "openaustraliafoundation_org_au_zone_id" {
  default = "5774055545c9ecb0d16b723857185e0e"
}

## oaf.org.au
# A records
resource "cloudflare_record" "oaf_root" {
  zone_id = var.oaf_org_au_zone_id
  name    = "oaf.org.au"
  type    = "A"
  value   = aws_eip.oaf.public_ip
}

resource "cloudflare_record" "oaf_cuttlefish" {
  zone_id = var.oaf_org_au_zone_id
  name    = "cuttlefish.oaf.org.au"
  type    = "A"
  value   = var.cuttlefish_ipv4
}

resource "cloudflare_record" "oaf_cuttlefish_test" {
  zone_id = var.oaf_org_au_zone_id
  name    = "cuttlefish-test.oaf.org.au"
  type    = "A"
  value   = "45.79.111.242"
}

resource "cloudflare_record" "au_proxy" {
  zone_id = var.oaf_org_au_zone_id
  name    = "au.proxy.oaf.org.au"
  type    = "A"
  value   = aws_eip.au_proxy.public_ip
}

# AAAA records
resource "cloudflare_record" "oaf_aaaa_cuttlefish" {
  zone_id = var.oaf_org_au_zone_id
  name    = "cuttlefish.oaf.org.au"
  type    = "AAAA"
  value   = var.cuttlefish_ipv6
}

# CNAME records
resource "cloudflare_record" "oaf_test" {
  zone_id = var.oaf_org_au_zone_id
  name    = "test.oaf.org.au"
  type    = "CNAME"
  value   = "oaf.org.au"
}

resource "cloudflare_record" "oaf_www" {
  zone_id = var.oaf_org_au_zone_id
  name    = "www.oaf.org.au"
  type    = "CNAME"
  value   = "oaf.org.au"
}

# For campaign monitor
resource "cloudflare_record" "oaf_email" {
  zone_id = var.oaf_org_au_zone_id
  name    = "email.oaf.org.au"
  type    = "CNAME"
  value   = "cname.createsend.com"
}

# MX records
resource "cloudflare_record" "oaf_mx1" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "oaf.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_mx2" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "oaf.org.au"
  type     = "MX"
  priority = 20
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_mx3" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "oaf.org.au"
  type     = "MX"
  priority = 20
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_mx4" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "oaf.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "oaf_mx5" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "oaf.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx3.googlemail.com"
}

resource "cloudflare_record" "oaf_cuttlefish_mx1" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 1
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_cuttlefish_mx2" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 5
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_cuttlefish_mx3" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 5
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_cuttlefish_mx4" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "oaf_cuttlefish_mx5" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx3.googlemail.com"
}

#Front DNS records
resource "cloudflare_record" "oaf_cuttlefish_front_mx" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "front-mail.cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 100
  value    = "mx.sendgrid.net"
}

resource "cloudflare_record" "oaf_cuttlefish_front_spf" {
  zone_id = var.oaf_org_au_zone_id
  name    = "front-mail.cuttlefish.oaf.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:sendgrid.net ~all"
}

resource "cloudflare_record" "oaf_cuttlefish_front_domainkey" {
  zone_id = var.oaf_org_au_zone_id
  name    = "m1._domainkey.cuttlefish.oaf.org.au"
  type    = "TXT"
  value   = "k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4PZZJiwMfMB/CuIZ9yAtNEGzfKzQ7WC7hfGg8UyavtYlDDBgSP6P1AiTBTMzTQbLChvf+Ef5CK46w+RwmgWpL38sxRwjahk45aQxoMOk2FJm7iHnP6zAGUnqAiL8iCdTjn5sp/txNf22bXrx3YS54ePBrfZQxOvkOvE24XZKXXwIDAQAB"
}

# TXT records
resource "cloudflare_record" "oaf_spf" {
  zone_id = var.oaf_org_au_zone_id
  name    = "oaf.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:_spf.google.com ~all"
}

resource "cloudflare_record" "oaf_google_site_verification" {
  zone_id = var.oaf_org_au_zone_id
  name    = "oaf.org.au"
  type    = "TXT"
  value   = "google-site-verification=RLhe_zgIDJMxpFFYFewv0KaRlWQvH-JDBxxpEV-8noY"
}

resource "cloudflare_record" "oaf_cuttlefish_spf" {
  zone_id = var.oaf_org_au_zone_id
  name    = "cuttlefish.oaf.org.au"
  type    = "TXT"
  value   = "v=spf1 include:_spf.google.com ip4:${var.cuttlefish_ipv4} ip6:${var.cuttlefish_ipv6} -all"
}

resource "cloudflare_record" "oaf_cuttlefish_domainkey" {
  zone_id = var.oaf_org_au_zone_id
  name    = "cuttlefish._domainkey.cuttlefish.oaf.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvEPfY69ZLYEn+I8rXaRLpTTb9c8AAEdjlUIPAX5nZ2cPYRxA8eCO/AYgXGXXdvGYWUm7sDkil6oSlqZjLx3au31AOoPNimi8FT2QjSgDp/Qkd403ACW314Aio4lo39y+un4GK0ih6KDuJAcxSftoGd9DFViBkVUs8Cs/WhFnc2dkhKTpCtt8Mji+bNtTOYsFwAg8LC3tDnWg+V3UTqqFQBi476DemGPVjxtpe48uFjCQpGg8T0uW54cIKWiC3PWCU0Ksj3HVMhE8P33McW/VFyGAx+nDlc0i6VY3zZi2i86O9Z84j0bJm/607lFK/pCa/Rv8hSJz5Ksk2EkD0NKh0QIDAQAB"
}

# TODO: Remove this once the one below is up and running
resource "cloudflare_record" "oaf_domainkey" {
  zone_id = var.oaf_org_au_zone_id
  name    = "cuttlefish._domainkey.oaf.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7fLXgEr26+qIswukULxl1OIPfz2CZ1iPcy4+LsveWZKGi1mU4jcy2vregS8FOm1B/V2nI354jBxlEi4XLxElcThq7zrFcDLXPNkrCg7yyPCF3qBnISlWDF/EwB0wOE1VF3QcwcILdR9vzRHP2yo0uTkz+stZpzVgthfM4FAOd5vDQ+cYxCwKTtXyCBUHH+/c2KUYnKiAOEXmuOUfwdo7uAPdClyg8mPAqYzjEQtPlktulD3rLQp3bom5lkGVLzklfiD77JVK1PD1a9C2OItG55KYbie3EPrXLkecGMob1ulhvz7ml/bSx3bqDUcbelnVLlT9VjeRiEUWoSYzJxXoMwIDAQAB"
}

resource "cloudflare_record" "oaf_domainkey2" {
  zone_id = var.oaf_org_au_zone_id
  name    = "civicrm_37.cuttlefish._domainkey.oaf.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7fLXgEr26+qIswukULxl1OIPfz2CZ1iPcy4+LsveWZKGi1mU4jcy2vregS8FOm1B/V2nI354jBxlEi4XLxElcThq7zrFcDLXPNkrCg7yyPCF3qBnISlWDF/EwB0wOE1VF3QcwcILdR9vzRHP2yo0uTkz+stZpzVgthfM4FAOd5vDQ+cYxCwKTtXyCBUHH+/c2KUYnKiAOEXmuOUfwdo7uAPdClyg8mPAqYzjEQtPlktulD3rLQp3bom5lkGVLzklfiD77JVK1PD1a9C2OItG55KYbie3EPrXLkecGMob1ulhvz7ml/bSx3bqDUcbelnVLlT9VjeRiEUWoSYzJxXoMwIDAQAB"
}

resource "cloudflare_record" "oaf_domainkey_campaign_monitor" {
  zone_id = var.oaf_org_au_zone_id
  name    = "cm._domainkey.oaf.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC7c0O/Ihi0wMb89k9UvkFPqM00DWEcm5kgCkhSTHN5rKcMtlCrijBYqZQgBcig/M6Zl6o6z9nKp4egpJ9Yf8ndZEz/r7AcQIeTjLwxIIlFSbABuBoQPoxTUrIvzRCWUTgCocvi3sNrzxYvYfFPq7LmxjI+RzK3UD84rKBaJtYULwIDAQAB"
}

## openaustraliafoundation.org.au

# A records

resource "cloudflare_record" "oaf_alt_root" {
  zone_id = var.openaustraliafoundation_org_au_zone_id
  name    = "openaustraliafoundation.org.au"
  type    = "A"
  value   = aws_eip.oaf.public_ip
}

# CNAME records
resource "cloudflare_record" "oaf_alt_www" {
  zone_id = var.openaustraliafoundation_org_au_zone_id
  name    = "www.openaustraliafoundation.org.au"
  type    = "CNAME"
  value   = "openaustraliafoundation.org.au"
}

resource "cloudflare_record" "oaf_alt_test" {
  zone_id = var.openaustraliafoundation_org_au_zone_id
  name    = "test.openaustraliafoundation.org.au"
  type    = "CNAME"
  value   = "openaustraliafoundation.org.au"
}

# MX records
resource "cloudflare_record" "oaf_alt_mx1" {
  zone_id  = var.openaustraliafoundation_org_au_zone_id
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 1
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_alt_mx2" {
  zone_id  = var.openaustraliafoundation_org_au_zone_id
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 5
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_alt_mx3" {
  zone_id  = var.openaustraliafoundation_org_au_zone_id
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 5
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_alt_mx4" {
  zone_id  = var.openaustraliafoundation_org_au_zone_id
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "oaf_alt_mx5" {
  zone_id  = var.openaustraliafoundation_org_au_zone_id
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx3.googlemail.com"
}

# TXT records
resource "cloudflare_record" "oaf_alt_spf" {
  zone_id = var.openaustraliafoundation_org_au_zone_id
  name    = "openaustraliafoundation.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:_spf.google.com ~all"
}

resource "cloudflare_record" "oaf_alt_google_site_verification" {
  zone_id = var.openaustraliafoundation_org_au_zone_id
  name    = "openaustraliafoundation.org.au"
  type    = "TXT"
  value   = "google-site-verification=sNfu9GJBQDlBYvdsXm8b61JjxxPfDy2JH9ok2UKHu48"
}

#Front DNS records
resource "cloudflare_record" "oaf_front_mx" {
  zone_id  = var.oaf_org_au_zone_id
  name     = "front-mail.oaf.org.au"
  type     = "MX"
  priority = 100
  value    = "mx.sendgrid.net"
}

resource "cloudflare_record" "oaf_front_spf" {
  zone_id = var.oaf_org_au_zone_id
  name    = "front-mail.oaf.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:sendgrid.net ~all"
}

resource "cloudflare_record" "oaf_front_domainkey" {
  zone_id = var.oaf_org_au_zone_id
  name    = "m1._domainkey.oaf.org.au"
  type    = "TXT"
  value   = "k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4PZZJiwMfMB/CuIZ9yAtNEGzfKzQ7WC7hfGg8UyavtYlDDBgSP6P1AiTBTMzTQbLChvf+Ef5CK46w+RwmgWpL38sxRwjahk45aQxoMOk2FJm7iHnP6zAGUnqAiL8iCdTjn5sp/txNf22bXrx3YS54ePBrfZQxOvkOvE24XZKXXwIDAQAB"
}
