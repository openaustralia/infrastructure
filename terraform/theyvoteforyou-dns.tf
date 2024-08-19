variable "theyvoteforyou_org_au_zone_id" {
  default = "5ffc72ab294d0bdcd481fd19b9ab8326"
}

variable "theyvoteforyou_org_zone_id" {
  default = "4ea2ceb027e2299e27c8cc1a8c59b029"
}

variable "theyvoteforyou_com_au_zone_id" {
  default = "dd36844e39e23c27ae5f316bc516d692"
}

## theyvoteforyou.org.au

# A records
resource "cloudflare_record" "root" {
  zone_id = var.theyvoteforyou_org_au_zone_id
  name    = "theyvoteforyou.org.au"
  type    = "A"
  value   = aws_eip.theyvoteforyou.public_ip
}

# CNAME records

resource "cloudflare_record" "www" {
  zone_id = var.theyvoteforyou_org_au_zone_id
  name    = "www.theyvoteforyou.org.au"
  type    = "CNAME"
  value   = "theyvoteforyou.org.au"
}

resource "cloudflare_record" "test" {
  zone_id = var.theyvoteforyou_org_au_zone_id
  name    = "test.theyvoteforyou.org.au"
  type    = "CNAME"
  value   = "theyvoteforyou.org.au"
}

resource "cloudflare_record" "www_test" {
  zone_id = var.theyvoteforyou_org_au_zone_id
  name    = "www.test.theyvoteforyou.org.au"
  type    = "CNAME"
  value   = "theyvoteforyou.org.au"
}

resource "cloudflare_record" "email" {
  zone_id = var.theyvoteforyou_org_au_zone_id
  name    = "email.theyvoteforyou.org.au"
  type    = "CNAME"
  value   = "cuttlefish.io"
}

resource "cloudflare_record" "email2" {
  zone_id = var.theyvoteforyou_org_au_zone_id
  name    = "email2.theyvoteforyou.org.au"
  type    = "CNAME"
  value   = "cuttlefish.oaf.org.au"
}

# MX records

resource "cloudflare_record" "mx1" {
  zone_id  = var.theyvoteforyou_org_au_zone_id
  name     = "theyvoteforyou.org.au"
  type     = "MX"
  priority = 1
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "mx2" {
  zone_id  = var.theyvoteforyou_org_au_zone_id
  name     = "theyvoteforyou.org.au"
  type     = "MX"
  priority = 5
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "mx3" {
  zone_id  = var.theyvoteforyou_org_au_zone_id
  name     = "theyvoteforyou.org.au"
  type     = "MX"
  priority = 5
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "mx4" {
  zone_id  = var.theyvoteforyou_org_au_zone_id
  name     = "theyvoteforyou.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "mx5" {
  zone_id  = var.theyvoteforyou_org_au_zone_id
  name     = "theyvoteforyou.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx3.googlemail.com"
}

# TXT records

resource "cloudflare_record" "spf" {
  zone_id = var.theyvoteforyou_org_au_zone_id
  name    = "theyvoteforyou.org.au"
  type    = "TXT"
  value   = "v=spf1 include:_spf.google.com -all"
}

# TODO: Remove this once the one below is up and running
resource "cloudflare_record" "cuttlefish" {
  zone_id = var.theyvoteforyou_org_au_zone_id
  name    = "cuttlefish._domainkey.theyvoteforyou.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0toFOrXAOcbnS8LNeKQsetYEO4Qh1RLGCx9+prCDeXBgs0obFCPWyanqxiPL6WEZCv+Vj4TCBPfoVCR1G0hszOZIA1QCEx0tG4v3dE2QsS3tSVCl9ax1h0oi4fC5aJ7XdxI+e2JVcWwmSSCLoKbkJYpj+6VBr86jUZl6f3JeUH/RuIeS6jIHRFmM6Mz/BfzloxM2wbDK320DUs3yWkL3/RcwkT6ebI9oS+ZWIxKXAgEcreTG0JltgPR/ABPFNzms4mAtLwPojF/FAYzGCj6diGbB61LNcMwe0MrutvLucclhnSefG5E3GVNqLrQA1oXzwFLFsq1H0x8rFccm+GNAuQIDAQAB"
}

resource "cloudflare_record" "cuttlefish2" {
  zone_id = var.theyvoteforyou_org_au_zone_id
  name    = "they_vote_for_you_4.cuttlefish._domainkey.theyvoteforyou.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0toFOrXAOcbnS8LNeKQsetYEO4Qh1RLGCx9+prCDeXBgs0obFCPWyanqxiPL6WEZCv+Vj4TCBPfoVCR1G0hszOZIA1QCEx0tG4v3dE2QsS3tSVCl9ax1h0oi4fC5aJ7XdxI+e2JVcWwmSSCLoKbkJYpj+6VBr86jUZl6f3JeUH/RuIeS6jIHRFmM6Mz/BfzloxM2wbDK320DUs3yWkL3/RcwkT6ebI9oS+ZWIxKXAgEcreTG0JltgPR/ABPFNzms4mAtLwPojF/FAYzGCj6diGbB61LNcMwe0MrutvLucclhnSefG5E3GVNqLrQA1oXzwFLFsq1H0x8rFccm+GNAuQIDAQAB"
}

resource "cloudflare_record" "google_site_verification" {
  zone_id = var.theyvoteforyou_org_au_zone_id
  name    = "theyvoteforyou.org.au"
  type    = "TXT"
  value   = "google-site-verification=DHISCv3WoPmTzUWzYfzpeBd5NivPxC5a2s4uBdWZoY8"
}

resource "cloudflare_record" "facebook_domain_verification" {
  zone_id = var.theyvoteforyou_org_au_zone_id
  name    = "theyvoteforyou.org.au"
  type    = "TXT"
  value   = "facebook-domain-verification=gl65oi4ss3xepcuasglgxgqlhj1lbg"
}

resource "cloudflare_record" "tvfy_domainkey_google" {
  zone_id = var.theyvoteforyou_org_au_zone_id
  name    = "google._domainkey.theyvoteforyou.org.au"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6GEPSzIyB0M2Fpuk6nAJth9sE3xU30e7dn5Q1NihGNbBaxFP01qxohr6eP0F2OeokQI0Gk7/uxtl0mWNe7oCdgxjflX7DVW5B5jSpXUI3wM5sppFFvwen3joDhnWP4fnu8PLkBNTcJ32crG2u4BcyCBaz7bmM7utFZgnsTo1NuAaq6Hs5SU2nv4i5dPgbSF9UjjZ+/FfCXqzmQpmWHVGvyweHiVosXX/nZyYl9QeroT2YDpcD93DIidtiDR79QPDqLtqAk8lJFN9nyYo9DCnsxheROXHfPFlr1tkhYJJ+HxSnB368SZFH3HNzhvS9WYscjYYXHw1TtI972MOCtPqiwIDAQAB"
}

## theyvoteforyou.org

resource "cloudflare_record" "alt1_root" {
  zone_id = var.theyvoteforyou_org_zone_id
  name    = "theyvoteforyou.org"
  type    = "A"
  value   = aws_eip.theyvoteforyou.public_ip
}

resource "cloudflare_record" "alt1_www" {
  zone_id = var.theyvoteforyou_org_zone_id
  name    = "www.theyvoteforyou.org"
  type    = "CNAME"
  value   = "theyvoteforyou.org"
}

## theyvoteforyou.com.au

resource "cloudflare_record" "alt2_root" {
  zone_id = var.theyvoteforyou_com_au_zone_id
  name    = "theyvoteforyou.com.au"
  type    = "A"
  value   = aws_eip.theyvoteforyou.public_ip
}

resource "cloudflare_record" "alt2_www" {
  zone_id = var.theyvoteforyou_com_au_zone_id
  name    = "www.theyvoteforyou.com.au"
  type    = "CNAME"
  value   = "theyvoteforyou.com.au"
}
