variable "openaustralia_org_zone_id" {
  default = "6f375d3f3dcd53599e538454c02161b2"
}

variable "openaustralia_org_au_zone_id" {
  default = "f8ae8cc5a255e25cc39bbb91177dfc47"
}

## openaustralia.org
# A records
resource "cloudflare_record" "oa_root" {
  zone_id = var.openaustralia_org_zone_id
  name    = "openaustralia.org"
  type    = "A"
  value   = aws_eip.openaustralia.public_ip
}

# CNAME records
resource "cloudflare_record" "oa_www" {
  zone_id = var.openaustralia_org_zone_id
  name    = "www.openaustralia.org"
  type    = "CNAME"
  value   = "openaustralia.org"
}

resource "cloudflare_record" "oa_test" {
  zone_id = var.openaustralia_org_zone_id
  name    = "test.openaustralia.org"
  type    = "CNAME"
  value   = "openaustralia.org"
}

# TODO: This should point at oaf.org.au
resource "cloudflare_record" "oa_blog" {
  zone_id = var.openaustralia_org_zone_id
  name    = "blog.openaustralia.org"
  type    = "CNAME"
  value   = "openaustralia.org"
}

resource "cloudflare_record" "oa_data" {
  zone_id = var.openaustralia_org_zone_id
  name    = "data.openaustralia.org"
  type    = "CNAME"
  value   = "openaustralia.org"
}

resource "cloudflare_record" "oa_software" {
  zone_id = var.openaustralia_org_zone_id
  name    = "software.openaustralia.org"
  type    = "CNAME"
  value   = "openaustralia.org"
}

resource "cloudflare_record" "oa_hackfest" {
  zone_id = var.openaustralia_org_zone_id
  name    = "hackfest.openaustralia.org"
  type    = "CNAME"
  value   = "ghs.google.com"
}

# MX records
resource "cloudflare_record" "oa_mx1" {
  zone_id  = var.openaustralia_org_zone_id
  name     = "openaustralia.org"
  type     = "MX"
  priority = 10
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "oa_mx2" {
  zone_id  = var.openaustralia_org_zone_id
  name     = "openaustralia.org"
  type     = "MX"
  priority = 20
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "oa_mx3" {
  zone_id  = var.openaustralia_org_zone_id
  name     = "openaustralia.org"
  type     = "MX"
  priority = 20
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "oa_mx4" {
  zone_id  = var.openaustralia_org_zone_id
  name     = "openaustralia.org"
  type     = "MX"
  priority = 30
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "oa_mx5" {
  zone_id  = var.openaustralia_org_zone_id
  name     = "openaustralia.org"
  type     = "MX"
  priority = 30
  value    = "aspmx3.googlemail.com"
}

resource "cloudflare_record" "oa_mx6" {
  zone_id  = var.openaustralia_org_zone_id
  name     = "openaustralia.org"
  type     = "MX"
  priority = 30
  value    = "aspmx4.googlemail.com"
}

resource "cloudflare_record" "oa_mx7" {
  zone_id  = var.openaustralia_org_zone_id
  name     = "openaustralia.org"
  type     = "MX"
  priority = 30
  value    = "aspmx5.googlemail.com"
}

# TXT records
resource "cloudflare_record" "oa_spf" {
  zone_id = var.openaustralia_org_zone_id
  name    = "openaustralia.org"
  type    = "TXT"
  value   = "v=spf1 a include:_spf.google.com ~all"
}

# TODO: Remove this once the one below is up and running
resource "cloudflare_record" "oa_cuttlefish_domainkey" {
  zone_id = var.openaustralia_org_zone_id
  name    = "cuttlefish._domainkey.openaustralia.org"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnTduUSfwRbdTef45qgzmJ75zTtwiFgtadq/KFfY18/1plQiSSvzpOTNZQjuPW+5X9AeHQhPGtrxLd26ho/V/8FTj2YiAkpi0uwjPBMiERNhOYT9AJzImNpTmFaa9Sq2JXnhYJQHZhlEVu2iE3ZQEZ+3gIbgvS23vFSYwv3n3HwcbAo3epYCekVglKBZvbGvChXZvmN90wz5ovTv74VPOiq96xPWkzcbA5CEiEGfJT8VqNdciQlbEy3Mpijyj/2qPvwZzDCG2xVS47FUr7xYXPRd/JUx7qDw+xlaFUQuT9S6/6zYWwJW7qJ4REIPvC/paORPfnsyqk8c6MIOH9nMXzQIDAQAB"
}

resource "cloudflare_record" "oa_cuttlefish_domainkey2" {
  zone_id = var.openaustralia_org_zone_id
  name    = "php_14.cuttlefish._domainkey.openaustralia.org"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnTduUSfwRbdTef45qgzmJ75zTtwiFgtadq/KFfY18/1plQiSSvzpOTNZQjuPW+5X9AeHQhPGtrxLd26ho/V/8FTj2YiAkpi0uwjPBMiERNhOYT9AJzImNpTmFaa9Sq2JXnhYJQHZhlEVu2iE3ZQEZ+3gIbgvS23vFSYwv3n3HwcbAo3epYCekVglKBZvbGvChXZvmN90wz5ovTv74VPOiq96xPWkzcbA5CEiEGfJT8VqNdciQlbEy3Mpijyj/2qPvwZzDCG2xVS47FUr7xYXPRd/JUx7qDw+xlaFUQuT9S6/6zYWwJW7qJ4REIPvC/paORPfnsyqk8c6MIOH9nMXzQIDAQAB"
}

## openaustralia.org.au

# A records
resource "cloudflare_record" "oa_alt_root" {
  zone_id = var.openaustralia_org_au_zone_id
  name    = "openaustralia.org.au"
  type    = "A"
  value   = aws_eip.openaustralia.public_ip
}

# CNAME records

resource "cloudflare_record" "oa_alt_www" {
  zone_id = var.openaustralia_org_au_zone_id
  name    = "www.openaustralia.org.au"
  type    = "CNAME"
  value   = "openaustralia.org.au"
}

resource "cloudflare_record" "oa_alt_test" {
  zone_id = var.openaustralia_org_au_zone_id
  name    = "test.openaustralia.org.au"
  type    = "CNAME"
  value   = "openaustralia.org.au"
}

resource "cloudflare_record" "oa_alt_www_test" {
  zone_id = var.openaustralia_org_au_zone_id
  name    = "www.test.openaustralia.org.au"
  type    = "CNAME"
  value   = "openaustralia.org.au"
}

resource "cloudflare_record" "oa_alt_data" {
  zone_id = var.openaustralia_org_au_zone_id
  name    = "data.openaustralia.org.au"
  type    = "CNAME"
  value   = "openaustralia.org.au"
}

resource "cloudflare_record" "oa_alt_software" {
  zone_id = var.openaustralia_org_au_zone_id
  name    = "software.openaustralia.org.au"
  type    = "CNAME"
  value   = "openaustralia.org.au"
}

# MX records
resource "cloudflare_record" "oa_alt_mx1" {
  zone_id  = var.openaustralia_org_au_zone_id
  name     = "openaustralia.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "oa_alt_mx2" {
  zone_id  = var.openaustralia_org_au_zone_id
  name     = "openaustralia.org.au"
  type     = "MX"
  priority = 20
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "oa_alt_mx3" {
  zone_id  = var.openaustralia_org_au_zone_id
  name     = "openaustralia.org.au"
  type     = "MX"
  priority = 20
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "oa_alt_mx4" {
  zone_id  = var.openaustralia_org_au_zone_id
  name     = "openaustralia.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "oa_alt_mx5" {
  zone_id  = var.openaustralia_org_au_zone_id
  name     = "openaustralia.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx3.googlemail.com"
}

resource "cloudflare_record" "oa_alt_mx6" {
  zone_id  = var.openaustralia_org_au_zone_id
  name     = "openaustralia.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx4.googlemail.com"
}

resource "cloudflare_record" "oa_alt_mx7" {
  zone_id  = var.openaustralia_org_au_zone_id
  name     = "openaustralia.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx5.googlemail.com"
}

# TXT records
resource "cloudflare_record" "oa_alt_spf" {
  zone_id = var.openaustralia_org_au_zone_id
  name    = "openaustralia.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:_spf.google.com ~all"
}

resource "cloudflare_record" "oa_alt_google_site_verification" {
  zone_id = var.openaustralia_org_au_zone_id
  name    = "openaustralia.org.au"
  type    = "TXT"
  value   = "google-site-verification=1xl-YdNs-D67htH3q438bFSGf1ThVHap5vXIFS6J0dI"
}

resource "cloudflare_record" "oa_alt_facebook_domain_verification" {
  zone_id = var.openaustralia_org_au_zone_id
  name    = "openaustralia.org.au"
  type    = "TXT"
  value   = "facebook-domain-verification=9fhej8uj8j643zkpahnblrfsst6iz5"
}

#Front DNS records
resource "cloudflare_record" "oaf_oa_alt_front_mx" {
  zone_id  = var.openaustralia_org_au_zone_id
  name     = "front-mail.openaustralia.org.au"
  type     = "MX"
  priority = 100
  value    = "mx.sendgrid.net"
}

resource "cloudflare_record" "oaf_oa_alt_front_spf" {
  zone_id = var.openaustralia_org_au_zone_id
  name    = "front-mail.openaustralia.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:sendgrid.net ~all"
}

resource "cloudflare_record" "oaf_oa_alt_front_domainkey" {
  zone_id = var.openaustralia_org_au_zone_id
  name    = "m1._domainkey.openaustralia.org.au"
  type    = "TXT"
  value   = "k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4PZZJiwMfMB/CuIZ9yAtNEGzfKzQ7WC7hfGg8UyavtYlDDBgSP6P1AiTBTMzTQbLChvf+Ef5CK46w+RwmgWpL38sxRwjahk45aQxoMOk2FJm7iHnP6zAGUnqAiL8iCdTjn5sp/txNf22bXrx3YS54ePBrfZQxOvkOvE24XZKXXwIDAQAB"
}
