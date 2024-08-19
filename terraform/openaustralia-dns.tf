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

resource "cloudflare_record" "oa_google_domainkey" {
  zone_id = var.openaustralia_org_zone_id
  name    = "google._domainkey.openaustralia.org"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyElfjTkZNV7cZIExju+igJVVoL57U39ZNt3d0slj3IAjnP9p6zgB0IiIdTTj9Ak2o9e0Ni0y53QnNvW2bgbOPw1dCT1HgOyNwqQniTPAEbFv/HtwOT6oD+dMeBQvFvIwtdMAj/ZOoQlAX4M8dn/Z9I8NWpKqNLLjQiuMtapFRaJCVKMtiqVhqnlYseuRLC14LNm/juAq11g/p9wFbuHcUJg30nZinOJEvDYck9Vw1JXACTkZM70GtWCobqd0CZHvPK7raZoGfRBSpqMVfTY2MNvvuK3riZ2RloSCM6EkF8aqf27DKTtGp6/EYbibTEprqwWy8/Pvap+hPHtbH87JrQIDAQAB"
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

resource "cloudflare_record" "oa_alt_domainkey_google" {
  zone_id = var.openaustralia_org_au_zone_id
  name    = "google._domainkey.openaustralia.org.au"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlL0dk9aaopGcbFKfugmxVqdUKCnpYTrnQj0Sz6RW1a+kFK44snSraBdMe6B14mvfUH1xkIuEiuKKWYIkYq5FHHZYcszVwt66FieU6HTaOvMNwDuXEJgU2zMIvGsUNiDO87CiEMZf0KhqyTrXIldVO/d9A5U7iZRy4poIKOQlm6NNEk6brfUXHct9S/Z4H6dlaowxUdjIp37838/U0AVTDiYYbSDrv2w60e1zTZy1y/9YXEGPlDpue4ijjJz1tjvJtS6cxfKT8elmXEOAo5j45K8NONJ4bEGNmTJxPMQwox0gBFwXwrf7pd4uYUpJW6GH9/vx7AW/jZe0SafCV/f0NQIDAQAB"
}
