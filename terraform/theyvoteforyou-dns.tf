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

#Front DNS records
resource "cloudflare_record" "front_mx" {
  zone_id  = var.theyvoteforyou_org_au_zone_id
  name     = "front-mail.theyvoteforyou.org.au"
  type     = "MX"
  priority = 100
  value    = "mx.sendgrid.net"
}

resource "cloudflare_record" "front_spf" {
  zone_id = var.theyvoteforyou_org_au_zone_id
  name    = "front-mail.theyvoteforyou.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:sendgrid.net ~all"
}

resource "cloudflare_record" "front_domainkey" {
  zone_id = var.theyvoteforyou_org_au_zone_id
  name    = "m1._domainkey.theyvoteforyou.org.au"
  type    = "TXT"
  value   = "k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4PZZJiwMfMB/CuIZ9yAtNEGzfKzQ7WC7hfGg8UyavtYlDDBgSP6P1AiTBTMzTQbLChvf+Ef5CK46w+RwmgWpL38sxRwjahk45aQxoMOk2FJm7iHnP6zAGUnqAiL8iCdTjn5sp/txNf22bXrx3YS54ePBrfZQxOvkOvE24XZKXXwIDAQAB"
}
