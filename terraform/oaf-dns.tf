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

resource "cloudflare_record" "au_proxy" {
  zone_id = var.oaf_org_au_zone_id
  name    = "au.proxy.oaf.org.au"
  type    = "A"
  value   = aws_eip.au_proxy.public_ip
}

resource "cloudflare_record" "web_metabase" {
  zone_id = var.oaf_org_au_zone_id
  name    = "web.metabase.oaf.org.au"
  type    = "A"
  value   = aws_eip.metabase.public_ip
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

resource "cloudflare_record" "metabase" {
  zone_id = var.oaf_org_au_zone_id
  name    = "metabase.oaf.org.au"
  type    = "CNAME"
  value   = aws_lb.main.dns_name
}

# For mastodon hosting

resource "cloudflare_record" "social" {
  zone_id = var.oaf_org_au_zone_id
  name    = "social.oaf.org.au"
  type    = "CNAME"
  value   = "vip.masto.host"
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

resource "cloudflare_record" "oaf_facebook_domain_verification" {
  zone_id = var.oaf_org_au_zone_id
  name    = "oaf.org.au"
  type    = "TXT"
  value   = "facebook-domain-verification=hfy8rxjyjsmjynz68xr373fy86lg4o"
}

resource "cloudflare_record" "oaf_domainkey_campaign_monitor" {
  zone_id = var.oaf_org_au_zone_id
  name    = "cm._domainkey.oaf.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC7c0O/Ihi0wMb89k9UvkFPqM00DWEcm5kgCkhSTHN5rKcMtlCrijBYqZQgBcig/M6Zl6o6z9nKp4egpJ9Yf8ndZEz/r7AcQIeTjLwxIIlFSbABuBoQPoxTUrIvzRCWUTgCocvi3sNrzxYvYfFPq7LmxjI+RzK3UD84rKBaJtYULwIDAQAB"
}

resource "cloudflare_record" "oaf_github_challenge" {
  zone_id = var.oaf_org_au_zone_id
  name    = "_github-challenge-openaustralia.www.oaf.org.au"
  type    = "TXT"
  value   = "6c5d1d8cf8"
}

resource "cloudflare_record" "oaf_github_challenge2" {
  zone_id = var.oaf_org_au_zone_id
  name    = "_github-challenge-openaustralia.oaf.org.au"
  type    = "TXT"
  value   = "209f2b7179"
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
