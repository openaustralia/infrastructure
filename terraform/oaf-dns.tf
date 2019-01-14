## oaf.org.au
# A records
resource "cloudflare_record" "oaf_root" {
  domain = "oaf.org.au"
  name   = "oaf.org.au"
  type   = "A"
  value  = "${aws_eip.oaf.public_ip}"
}

resource "cloudflare_record" "oaf_cuttlefish" {
  domain = "oaf.org.au"
  name   = "cuttlefish.oaf.org.au"
  type   = "A"
  value  = "${var.cuttlefish_ipv4}"
}

# AAAA records
resource "cloudflare_record" "oaf_aaaa_cuttlefish" {
  domain = "oaf.org.au"
  name   = "cuttlefish.oaf.org.au"
  type   = "AAAA"
  value  = "${var.cuttlefish_ipv6}"
}

# CNAME records
resource "cloudflare_record" "oaf_test" {
  domain = "oaf.org.au"
  name   = "test.oaf.org.au"
  type   = "CNAME"
  value  = "oaf.org.au"
}

resource "cloudflare_record" "oaf_www" {
  domain = "oaf.org.au"
  name   = "www.oaf.org.au"
  type   = "CNAME"
  value  = "oaf.org.au"
}

# MX records
resource "cloudflare_record" "oaf_mx1" {
  domain   = "oaf.org.au"
  name     = "oaf.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_mx2" {
  domain   = "oaf.org.au"
  name     = "oaf.org.au"
  type     = "MX"
  priority = 20
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_mx3" {
  domain   = "oaf.org.au"
  name     = "oaf.org.au"
  type     = "MX"
  priority = 20
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_mx4" {
  domain   = "oaf.org.au"
  name     = "oaf.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "oaf_mx5" {
  domain   = "oaf.org.au"
  name     = "oaf.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx3.googlemail.com"
}

resource "cloudflare_record" "oaf_cuttlefish_mx1" {
  domain   = "oaf.org.au"
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 1
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_cuttlefish_mx2" {
  domain   = "oaf.org.au"
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 5
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_cuttlefish_mx3" {
  domain   = "oaf.org.au"
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 5
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_cuttlefish_mx4" {
  domain   = "oaf.org.au"
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "oaf_cuttlefish_mx5" {
  domain   = "oaf.org.au"
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx3.googlemail.com"
}

#Front DNS records
resource "cloudflare_record" "oaf_cuttlefish_front_mx" {
  domain = "oaf.org.au"
  name = "front-mail.cuttlefish.oaf.org.au"
  type = "MX"
  priority = 100
  value = "mx.sendgrid.net"
}

resource "cloudflare_record" "oaf_cuttlefish_front_spf" {
  domain = "oaf.org.au"
  name   = "front-mail.cuttlefish.oaf.org.au"
  type   = "TXT"
  value  = "v=spf1 a include:sendgrid.net ~all"
}

resource "cloudflare_record" "oaf_cuttlefish_front_domainkey" {
  domain = "oaf.org.au"
  name   = "m1._domainkey.cuttlefish.oaf.org.au"
  type   = "TXT"
  value  = "k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4PZZJiwMfMB/CuIZ9yAtNEGzfKzQ7WC7hfGg8UyavtYlDDBgSP6P1AiTBTMzTQbLChvf+Ef5CK46w+RwmgWpL38sxRwjahk45aQxoMOk2FJm7iHnP6zAGUnqAiL8iCdTjn5sp/txNf22bXrx3YS54ePBrfZQxOvkOvE24XZKXXwIDAQAB"
}

# TXT records
resource "cloudflare_record" "oaf_spf" {
  domain = "oaf.org.au"
  name   = "oaf.org.au"
  type   = "TXT"
  value  = "v=spf1 a include:_spf.google.com ~all"
}

resource "cloudflare_record" "oaf_google_site_verification" {
  domain = "oaf.org.au"
  name   = "oaf.org.au"
  type   = "TXT"
  value  = "google-site-verification=RLhe_zgIDJMxpFFYFewv0KaRlWQvH-JDBxxpEV-8noY"
}

resource "cloudflare_record" "oaf_cuttlefish_spf" {
  domain = "oaf.org.au"
  name   = "cuttlefish.oaf.org.au"
  type   = "TXT"
  value  = "v=spf1 include:_spf.google.com ip4:${var.cuttlefish_ipv4} ip6:${var.cuttlefish_ipv6} -all"
}

resource "cloudflare_record" "oaf_cuttlefish_domainkey" {
  domain = "oaf.org.au"
  name   = "cuttlefish._domainkey.cuttlefish.oaf.org.au"
  type   = "TXT"
  value  = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvEPfY69ZLYEn+I8rXaRLpTTb9c8AAEdjlUIPAX5nZ2cPYRxA8eCO/AYgXGXXdvGYWUm7sDkil6oSlqZjLx3au31AOoPNimi8FT2QjSgDp/Qkd403ACW314Aio4lo39y+un4GK0ih6KDuJAcxSftoGd9DFViBkVUs8Cs/WhFnc2dkhKTpCtt8Mji+bNtTOYsFwAg8LC3tDnWg+V3UTqqFQBi476DemGPVjxtpe48uFjCQpGg8T0uW54cIKWiC3PWCU0Ksj3HVMhE8P33McW/VFyGAx+nDlc0i6VY3zZi2i86O9Z84j0bJm/607lFK/pCa/Rv8hSJz5Ksk2EkD0NKh0QIDAQAB"
}

# TODO: Remove this once the one below is up and running
resource "cloudflare_record" "oaf_domainkey" {
  domain = "oaf.org.au"
  name   = "cuttlefish._domainkey.oaf.org.au"
  type   = "TXT"
  value  = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7fLXgEr26+qIswukULxl1OIPfz2CZ1iPcy4+LsveWZKGi1mU4jcy2vregS8FOm1B/V2nI354jBxlEi4XLxElcThq7zrFcDLXPNkrCg7yyPCF3qBnISlWDF/EwB0wOE1VF3QcwcILdR9vzRHP2yo0uTkz+stZpzVgthfM4FAOd5vDQ+cYxCwKTtXyCBUHH+/c2KUYnKiAOEXmuOUfwdo7uAPdClyg8mPAqYzjEQtPlktulD3rLQp3bom5lkGVLzklfiD77JVK1PD1a9C2OItG55KYbie3EPrXLkecGMob1ulhvz7ml/bSx3bqDUcbelnVLlT9VjeRiEUWoSYzJxXoMwIDAQAB"
}

resource "cloudflare_record" "oaf_domainkey2" {
  domain = "oaf.org.au"
  name   = "civicrm_37.cuttlefish._domainkey.oaf.org.au"
  type   = "TXT"
  value  = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7fLXgEr26+qIswukULxl1OIPfz2CZ1iPcy4+LsveWZKGi1mU4jcy2vregS8FOm1B/V2nI354jBxlEi4XLxElcThq7zrFcDLXPNkrCg7yyPCF3qBnISlWDF/EwB0wOE1VF3QcwcILdR9vzRHP2yo0uTkz+stZpzVgthfM4FAOd5vDQ+cYxCwKTtXyCBUHH+/c2KUYnKiAOEXmuOUfwdo7uAPdClyg8mPAqYzjEQtPlktulD3rLQp3bom5lkGVLzklfiD77JVK1PD1a9C2OItG55KYbie3EPrXLkecGMob1ulhvz7ml/bSx3bqDUcbelnVLlT9VjeRiEUWoSYzJxXoMwIDAQAB"
}

## openaustraliafoundation.org.au

# A records

resource "cloudflare_record" "oaf_alt_root" {
  domain = "openaustraliafoundation.org.au"
  name   = "openaustraliafoundation.org.au"
  type   = "A"
  value  = "${aws_eip.oaf.public_ip}"
}

# CNAME records
resource "cloudflare_record" "oaf_alt_www" {
  domain = "openaustraliafoundation.org.au"
  name   = "www.openaustraliafoundation.org.au"
  type   = "CNAME"
  value  = "openaustraliafoundation.org.au"
}

resource "cloudflare_record" "oaf_alt_test" {
  domain = "openaustraliafoundation.org.au"
  name   = "test.openaustraliafoundation.org.au"
  type   = "CNAME"
  value  = "openaustraliafoundation.org.au"
}

# MX records
resource "cloudflare_record" "oaf_alt_mx1" {
  domain   = "openaustraliafoundation.org.au"
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 1
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_alt_mx2" {
  domain   = "openaustraliafoundation.org.au"
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 5
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_alt_mx3" {
  domain   = "openaustraliafoundation.org.au"
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 5
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_alt_mx4" {
  domain   = "openaustraliafoundation.org.au"
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "oaf_alt_mx5" {
  domain   = "openaustraliafoundation.org.au"
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx3.googlemail.com"
}

# TXT records
resource "cloudflare_record" "oaf_alt_spf" {
  domain = "openaustraliafoundation.org.au"
  name   = "openaustraliafoundation.org.au"
  type   = "TXT"
  value  = "v=spf1 a include:_spf.google.com ~all"
}

resource "cloudflare_record" "oaf_alt_google_site_verification" {
  domain = "openaustraliafoundation.org.au"
  name   = "openaustraliafoundation.org.au"
  type   = "TXT"
  value  = "google-site-verification=sNfu9GJBQDlBYvdsXm8b61JjxxPfDy2JH9ok2UKHu48"
}

#Front DNS records
resource "cloudflare_record" "oaf_front_mx" {
  domain = "oaf.org.au"
  name = "front-mail.oaf.org.au"
  type = "MX"
  priority = 100
  value = "mx.sendgrid.net"
}

resource "cloudflare_record" "oaf_front_spf" {
  domain = "oaf.org.au"
  name   = "front-mail.oaf.org.au"
  type   = "TXT"
  value  = "v=spf1 a include:sendgrid.net ~all"
}

resource "cloudflare_record" "oaf_front_domainkey" {
  domain = "oaf.org.au"
  name   = "m1._domainkey.oaf.org.au"
  type   = "TXT"
  value  = "k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4PZZJiwMfMB/CuIZ9yAtNEGzfKzQ7WC7hfGg8UyavtYlDDBgSP6P1AiTBTMzTQbLChvf+Ef5CK46w+RwmgWpL38sxRwjahk45aQxoMOk2FJm7iHnP6zAGUnqAiL8iCdTjn5sp/txNf22bXrx3YS54ePBrfZQxOvkOvE24XZKXXwIDAQAB"
}
