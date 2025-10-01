resource "cloudflare_zone" "org" {
  account_id = var.cloudflare_account_id
  plan       = "business"
  zone       = "openaustralia.org"
}

resource "cloudflare_zone" "org_au" {
  account_id = var.cloudflare_account_id
  plan       = "business"
  zone       = "openaustralia.org.au"
}

## openaustralia.org
# A records
resource "cloudflare_record" "root" {
  zone_id = cloudflare_zone.org.id
  name    = "openaustralia.org"
  type    = "A"
  value   = aws_eip.main.public_ip
}

# CNAME records
resource "cloudflare_record" "www" {
  zone_id = cloudflare_zone.org.id
  name    = "www.openaustralia.org"
  type    = "CNAME"
  value   = "openaustralia.org"
}

resource "cloudflare_record" "test" {
  zone_id = cloudflare_zone.org.id
  name    = "test.openaustralia.org"
  type    = "CNAME"
  value   = "openaustralia.org"
}

# TODO: This should point at oaf.org.au
resource "cloudflare_record" "blog" {
  zone_id = cloudflare_zone.org.id
  name    = "blog.openaustralia.org"
  type    = "CNAME"
  value   = "openaustralia.org"
}

resource "cloudflare_record" "data" {
  zone_id = cloudflare_zone.org.id
  name    = "data.openaustralia.org"
  type    = "CNAME"
  value   = "openaustralia.org"
}

resource "cloudflare_record" "software" {
  zone_id = cloudflare_zone.org.id
  name    = "software.openaustralia.org"
  type    = "CNAME"
  value   = "openaustralia.org"
}

resource "cloudflare_record" "hackfest" {
  zone_id = cloudflare_zone.org.id
  name    = "hackfest.openaustralia.org"
  type    = "CNAME"
  value   = "ghs.google.com"
}

# MX records

# We can now use a single MX record for Google workspace
resource "cloudflare_record" "mx" {
  zone_id  = cloudflare_zone.org.id
  name     = "openaustralia.org"
  type     = "MX"
  priority = 1
  value    = "smtp.google.com"
}

# TXT records
resource "cloudflare_record" "spf" {
  zone_id = cloudflare_zone.org.id
  name    = "openaustralia.org"
  type    = "TXT"
  value   = "v=spf1 a include:_spf.google.com ~all"
}

# TODO: Remove this once the one below is up and running
resource "cloudflare_record" "cuttlefish_domainkey" {
  zone_id = cloudflare_zone.org.id
  name    = "cuttlefish._domainkey.openaustralia.org"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnTduUSfwRbdTef45qgzmJ75zTtwiFgtadq/KFfY18/1plQiSSvzpOTNZQjuPW+5X9AeHQhPGtrxLd26ho/V/8FTj2YiAkpi0uwjPBMiERNhOYT9AJzImNpTmFaa9Sq2JXnhYJQHZhlEVu2iE3ZQEZ+3gIbgvS23vFSYwv3n3HwcbAo3epYCekVglKBZvbGvChXZvmN90wz5ovTv74VPOiq96xPWkzcbA5CEiEGfJT8VqNdciQlbEy3Mpijyj/2qPvwZzDCG2xVS47FUr7xYXPRd/JUx7qDw+xlaFUQuT9S6/6zYWwJW7qJ4REIPvC/paORPfnsyqk8c6MIOH9nMXzQIDAQAB"
}

resource "cloudflare_record" "cuttlefish_domainkey2" {
  zone_id = cloudflare_zone.org.id
  name    = "php_14.cuttlefish._domainkey.openaustralia.org"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnTduUSfwRbdTef45qgzmJ75zTtwiFgtadq/KFfY18/1plQiSSvzpOTNZQjuPW+5X9AeHQhPGtrxLd26ho/V/8FTj2YiAkpi0uwjPBMiERNhOYT9AJzImNpTmFaa9Sq2JXnhYJQHZhlEVu2iE3ZQEZ+3gIbgvS23vFSYwv3n3HwcbAo3epYCekVglKBZvbGvChXZvmN90wz5ovTv74VPOiq96xPWkzcbA5CEiEGfJT8VqNdciQlbEy3Mpijyj/2qPvwZzDCG2xVS47FUr7xYXPRd/JUx7qDw+xlaFUQuT9S6/6zYWwJW7qJ4REIPvC/paORPfnsyqk8c6MIOH9nMXzQIDAQAB"
}

resource "cloudflare_record" "google_domainkey" {
  zone_id = cloudflare_zone.org.id
  name    = "google._domainkey.openaustralia.org"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyElfjTkZNV7cZIExju+igJVVoL57U39ZNt3d0slj3IAjnP9p6zgB0IiIdTTj9Ak2o9e0Ni0y53QnNvW2bgbOPw1dCT1HgOyNwqQniTPAEbFv/HtwOT6oD+dMeBQvFvIwtdMAj/ZOoQlAX4M8dn/Z9I8NWpKqNLLjQiuMtapFRaJCVKMtiqVhqnlYseuRLC14LNm/juAq11g/p9wFbuHcUJg30nZinOJEvDYck9Vw1JXACTkZM70GtWCobqd0CZHvPK7raZoGfRBSpqMVfTY2MNvvuK3riZ2RloSCM6EkF8aqf27DKTtGp6/EYbibTEprqwWy8/Pvap+hPHtbH87JrQIDAQAB"
}

# For the time being we're just using DMARC records to get some data on what's
# happening with email that we're sending (and whether anyone else is impersonating
# us).
# We're using a free service provided by https://dmarc.postmarkapp.com/
# This generates a weekly DMARC report which gets sent by email on Monday mornings
# Report goes to webmaster@openaustralia.org
resource "cloudflare_record" "dmarc" {
  zone_id = cloudflare_zone.org.id
  name    = "_dmarc.openaustralia.org"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+dkbgzuudi8i@dmarc.postmarkapp.com; sp=none; aspf=r;"
}

## openaustralia.org.au

# A records
resource "cloudflare_record" "alt_root" {
  zone_id = cloudflare_zone.org_au.id
  name    = "openaustralia.org.au"
  type    = "A"
  value   = aws_eip.main.public_ip
}

# CNAME records

resource "cloudflare_record" "alt_www" {
  zone_id = cloudflare_zone.org_au.id
  name    = "www.openaustralia.org.au"
  type    = "CNAME"
  value   = "openaustralia.org.au"
}

resource "cloudflare_record" "alt_test" {
  zone_id = cloudflare_zone.org_au.id
  name    = "test.openaustralia.org.au"
  type    = "CNAME"
  value   = "openaustralia.org.au"
}

resource "cloudflare_record" "alt_www_test" {
  zone_id = cloudflare_zone.org_au.id
  name    = "www.test.openaustralia.org.au"
  type    = "CNAME"
  value   = "openaustralia.org.au"
}

resource "cloudflare_record" "alt_data" {
  zone_id = cloudflare_zone.org_au.id
  name    = "data.openaustralia.org.au"
  type    = "CNAME"
  value   = "openaustralia.org.au"
}

resource "cloudflare_record" "alt_software" {
  zone_id = cloudflare_zone.org_au.id
  name    = "software.openaustralia.org.au"
  type    = "CNAME"
  value   = "openaustralia.org.au"
}

# MX records

# We can now use a single MX record for Google workspace
resource "cloudflare_record" "alt_mx" {
  zone_id  = cloudflare_zone.org_au.id
  name     = "openaustralia.org.au"
  type     = "MX"
  priority = 1
  value    = "smtp.google.com"
}

# TXT records
resource "cloudflare_record" "alt_spf" {
  zone_id = cloudflare_zone.org_au.id
  name    = "openaustralia.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:_spf.google.com ~all"
}

resource "cloudflare_record" "alt_google_site_verification" {
  zone_id = cloudflare_zone.org_au.id
  name    = "openaustralia.org.au"
  type    = "TXT"
  value   = "google-site-verification=1xl-YdNs-D67htH3q438bFSGf1ThVHap5vXIFS6J0dI"
}

resource "cloudflare_record" "alt_facebook_domain_verification" {
  zone_id = cloudflare_zone.org_au.id
  name    = "openaustralia.org.au"
  type    = "TXT"
  value   = "facebook-domain-verification=9fhej8uj8j643zkpahnblrfsst6iz5"
}

resource "cloudflare_record" "alt_domainkey_google" {
  zone_id = cloudflare_zone.org_au.id
  name    = "google._domainkey.openaustralia.org.au"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlL0dk9aaopGcbFKfugmxVqdUKCnpYTrnQj0Sz6RW1a+kFK44snSraBdMe6B14mvfUH1xkIuEiuKKWYIkYq5FHHZYcszVwt66FieU6HTaOvMNwDuXEJgU2zMIvGsUNiDO87CiEMZf0KhqyTrXIldVO/d9A5U7iZRy4poIKOQlm6NNEk6brfUXHct9S/Z4H6dlaowxUdjIp37838/U0AVTDiYYbSDrv2w60e1zTZy1y/9YXEGPlDpue4ijjJz1tjvJtS6cxfKT8elmXEOAo5j45K8NONJ4bEGNmTJxPMQwox0gBFwXwrf7pd4uYUpJW6GH9/vx7AW/jZe0SafCV/f0NQIDAQAB"
}

# For the time being we're just using DMARC records to get some data on what's
# happening with email that we're sending (and whether anyone else is impersonating
# us).
# We're using a free service provided by https://dmarc.postmarkapp.com/
# This generates a weekly DMARC report which gets sent by email on Monday mornings
# Report goes to webmaster@openaustralia.org.au
resource "cloudflare_record" "alt_dmarc" {
  zone_id = cloudflare_zone.org_au.id
  name    = "_dmarc.openaustralia.org.au"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+no6xy3wrymr@dmarc.postmarkapp.com; sp=none; aspf=r;"
}
