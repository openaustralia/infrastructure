## openaustralia.org
# A records
resource "cloudflare_record" "oa_root" {
  domain = "openaustralia.org"
  name   = "openaustralia.org"
  type   = "A"
  value  = "${aws_eip.octopus.public_ip}"
}

# TODO: Remove this
resource "cloudflare_record" "oa_kedumba" {
  domain = "openaustralia.org"
  name   = "kedumba.openaustralia.org"
  type   = "A"
  value  = "103.243.244.10"
}

# CNAME records
resource "cloudflare_record" "oa_www" {
  domain = "openaustralia.org"
  name   = "www.openaustralia.org"
  type   = "CNAME"
  value  = "openaustralia.org"
}

resource "cloudflare_record" "oa_test" {
  domain = "openaustralia.org"
  name   = "test.openaustralia.org"
  type   = "CNAME"
  value  = "openaustralia.org"
}

# TODO: This should point at oaf.org.au
resource "cloudflare_record" "oa_blog" {
  domain = "openaustralia.org"
  name   = "blog.openaustralia.org"
  type   = "CNAME"
  value  = "openaustralia.org"
}

resource "cloudflare_record" "oa_data" {
  domain = "openaustralia.org"
  name   = "data.openaustralia.org"
  type   = "CNAME"
  value  = "openaustralia.org"
}

# TODO: Remove this?
resource "cloudflare_record" "oa_git" {
  domain = "openaustralia.org"
  name   = "git.openaustralia.org"
  type   = "CNAME"
  value  = "openaustralia.org"
}

resource "cloudflare_record" "oa_software" {
  domain = "openaustralia.org"
  name   = "software.openaustralia.org"
  type   = "CNAME"
  value  = "openaustralia.org"
}

# TODO: Remove this?
resource "cloudflare_record" "oa_wiki" {
  domain = "openaustralia.org"
  name   = "wiki.openaustralia.org"
  type   = "CNAME"
  value  = "openaustralia.org"
}

# TODO: Remove this?
resource "cloudflare_record" "oa_calendar" {
  domain = "openaustralia.org"
  name   = "calendar.openaustralia.org"
  type   = "CNAME"
  value  = "ghs.google.com"
}

# TODO: Remove this?
resource "cloudflare_record" "oa_groups" {
  domain = "openaustralia.org"
  name   = "groups.openaustralia.org"
  type   = "CNAME"
  value  = "ghs.google.com"
}

resource "cloudflare_record" "oa_hackfest" {
  domain = "openaustralia.org"
  name   = "hackfest.openaustralia.org"
  type   = "CNAME"
  value  = "ghs.google.com"
}

# TODO: Remove this?
resource "cloudflare_record" "oa_mail" {
  domain = "openaustralia.org"
  name   = "mail.openaustralia.org"
  type   = "CNAME"
  value  = "ghs.google.com"
}

# TODO: Remove this?
resource "cloudflare_record" "oa_start" {
  domain = "openaustralia.org"
  name   = "start.openaustralia.org"
  type   = "CNAME"
  value  = "ghs.google.com"
}

# TODO: Remove this?
resource "cloudflare_record" "oa_wave" {
  domain = "openaustralia.org"
  name   = "wave.openaustralia.org"
  type   = "CNAME"
  value  = "ghs.google.com"
}

# MX records
resource "cloudflare_record" "oa_mx1" {
  domain   = "openaustralia.org"
  name     = "openaustralia.org"
  type     = "MX"
  priority = 10
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "oa_mx2" {
  domain   = "openaustralia.org"
  name     = "openaustralia.org"
  type     = "MX"
  priority = 20
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "oa_mx3" {
  domain   = "openaustralia.org"
  name     = "openaustralia.org"
  type     = "MX"
  priority = 20
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "oa_mx4" {
  domain   = "openaustralia.org"
  name     = "openaustralia.org"
  type     = "MX"
  priority = 30
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "oa_mx5" {
  domain   = "openaustralia.org"
  name     = "openaustralia.org"
  type     = "MX"
  priority = 30
  value    = "aspmx3.googlemail.com"
}

resource "cloudflare_record" "oa_mx6" {
  domain   = "openaustralia.org"
  name     = "openaustralia.org"
  type     = "MX"
  priority = 30
  value    = "aspmx4.googlemail.com"
}

resource "cloudflare_record" "oa_mx7" {
  domain   = "openaustralia.org"
  name     = "openaustralia.org"
  type     = "MX"
  priority = 30
  value    = "aspmx5.googlemail.com"
}

# TXT records
resource "cloudflare_record" "oa_spf" {
  domain = "openaustralia.org"
  name   = "openaustralia.org"
  type   = "TXT"
  value  = "v=spf1 a include:_spf.google.com ~all"
}

resource "cloudflare_record" "oa_cuttlefish_domainkey" {
  domain = "openaustralia.org"
  name   = "cuttlefish._domainkey.openaustralia.org"
  type   = "TXT"
  value  = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnTduUSfwRbdTef45qgzmJ75zTtwiFgtadq/KFfY18/1plQiSSvzpOTNZQjuPW+5X9AeHQhPGtrxLd26ho/V/8FTj2YiAkpi0uwjPBMiERNhOYT9AJzImNpTmFaa9Sq2JXnhYJQHZhlEVu2iE3ZQEZ+3gIbgvS23vFSYwv3n3HwcbAo3epYCekVglKBZvbGvChXZvmN90wz5ovTv74VPOiq96xPWkzcbA5CEiEGfJT8VqNdciQlbEy3Mpijyj/2qPvwZzDCG2xVS47FUr7xYXPRd/JUx7qDw+xlaFUQuT9S6/6zYWwJW7qJ4REIPvC/paORPfnsyqk8c6MIOH9nMXzQIDAQAB"
}

## openaustralia.org.au

# A records
resource "cloudflare_record" "oa_alt_root" {
  domain = "openaustralia.org.au"
  name   = "openaustralia.org.au"
  type   = "A"
  value  = "${aws_eip.octopus.public_ip}"
}

# CNAME records

resource "cloudflare_record" "oa_alt_www" {
  domain = "openaustralia.org.au"
  name   = "www.openaustralia.org.au"
  type   = "CNAME"
  value  = "openaustralia.org.au"
}

resource "cloudflare_record" "oa_alt_data" {
  domain = "openaustralia.org.au"
  name   = "data.openaustralia.org.au"
  type   = "CNAME"
  value  = "openaustralia.org.au"
}

# MX records
resource "cloudflare_record" "oa_alt_mx1" {
  domain   = "openaustralia.org.au"
  name     = "openaustralia.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "oa_alt_mx2" {
  domain   = "openaustralia.org.au"
  name     = "openaustralia.org.au"
  type     = "MX"
  priority = 20
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "oa_alt_mx3" {
  domain   = "openaustralia.org.au"
  name     = "openaustralia.org.au"
  type     = "MX"
  priority = 20
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "oa_alt_mx4" {
  domain   = "openaustralia.org.au"
  name     = "openaustralia.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "oa_alt_mx5" {
  domain   = "openaustralia.org.au"
  name     = "openaustralia.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx3.googlemail.com"
}

resource "cloudflare_record" "oa_alt_mx6" {
  domain   = "openaustralia.org.au"
  name     = "openaustralia.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx4.googlemail.com"
}

resource "cloudflare_record" "oa_alt_mx7" {
  domain   = "openaustralia.org.au"
  name     = "openaustralia.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx5.googlemail.com"
}

# TXT records
resource "cloudflare_record" "oa_alt_spf" {
  domain = "openaustralia.org.au"
  name   = "openaustralia.org.au"
  type   = "TXT"
  value  = "v=spf1 a include:_spf.google.com ~all"
}
