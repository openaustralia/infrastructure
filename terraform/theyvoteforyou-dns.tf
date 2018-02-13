# Configure the DNSMadeEasy provider
provider "dme" {
  version    = "~> 0.1"
  akey       = "${var.dnsmadeeasy_akey}"
  skey       = "${var.dnsmadeeasy_skey}"
  usesandbox = false
}

provider "cloudflare" {
  version = "~> 0.1"
  email   = "${var.cloudflare_email}"
  token   = "${var.cloudflare_token}"
}

resource "cloudflare_record" "root" {
  domain = "theyvoteforyou.org.au"
  name   = "theyvoteforyou.org.au"
  type   = "A"
  value  = "${aws_eip.theyvoteforyou.public_ip}"
}

resource "cloudflare_record" "mx1" {
  domain   = "theyvoteforyou.org.au"
  name     = "theyvoteforyou.org.au"
  type     = "MX"
  priority = 1
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "mx2" {
  domain   = "theyvoteforyou.org.au"
  name     = "theyvoteforyou.org.au"
  type     = "MX"
  priority = 5
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "mx3" {
  domain   = "theyvoteforyou.org.au"
  name     = "theyvoteforyou.org.au"
  type     = "MX"
  priority = 5
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "mx4" {
  domain   = "theyvoteforyou.org.au"
  name     = "theyvoteforyou.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "mx5" {
  domain   = "theyvoteforyou.org.au"
  name     = "theyvoteforyou.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx3.googlemail.com"
}

resource "cloudflare_record" "spf" {
  domain   = "theyvoteforyou.org.au"
  name     = "theyvoteforyou.org.au"
  type     = "TXT"
  value    = "v=spf1 include:_spf.google.com -all"
}

resource "cloudflare_record" "cuttlefish" {
  domain   = "theyvoteforyou.org.au"
  name     = "cuttlefish._domainkey.theyvoteforyou.org.au"
  type     = "TXT"
  value    = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0toFOrXAOcbnS8LNeKQsetYEO4Qh1RLGCx9+prCDeXBgs0obFCPWyanqxiPL6WEZCv+Vj4TCBPfoVCR1G0hszOZIA1QCEx0tG4v3dE2QsS3tSVCl9ax1h0oi4fC5aJ7XdxI+e2JVcWwmSSCLoKbkJYpj+6VBr86jUZl6f3JeUH/RuIeS6jIHRFmM6Mz/BfzloxM2wbDK320DUs3yWkL3/RcwkT6ebI9oS+ZWIxKXAgEcreTG0JltgPR/ABPFNzms4mAtLwPojF/FAYzGCj6diGbB61LNcMwe0MrutvLucclhnSefG5E3GVNqLrQA1oXzwFLFsq1H0x8rFccm+GNAuQIDAQAB"
}

resource "cloudflare_record" "email" {
  domain   = "theyvoteforyou.org.au"
  name     = "email.theyvoteforyou.org.au"
  type     = "CNAME"
  value    = "cuttlefish.io"
}

resource "cloudflare_record" "email2" {
  domain   = "theyvoteforyou.org.au"
  name     = "email2.theyvoteforyou.org.au"
  type     = "CNAME"
  value    = "cuttlefish.oaf.org.au"
}

resource "cloudflare_record" "test" {
  domain   = "theyvoteforyou.org.au"
  name     = "test.theyvoteforyou.org.au"
  type     = "CNAME"
  value    = "theyvoteforyou.org.au"
}

resource "cloudflare_record" "www_test" {
  domain   = "theyvoteforyou.org.au"
  name     = "www.test.theyvoteforyou.org.au"
  type     = "CNAME"
  value    = "theyvoteforyou.org.au"
}

resource "cloudflare_record" "www" {
  domain   = "theyvoteforyou.org.au"
  name     = "www.theyvoteforyou.org.au"
  type     = "CNAME"
  value    = "theyvoteforyou.org.au"
}

resource "cloudflare_record" "alt1_root" {
  domain   = "theyvoteforyou.org"
  name     = "theyvoteforyou.org"
  type     = "A"
  value    = "${aws_eip.theyvoteforyou.public_ip}"
}

resource "cloudflare_record" "alt1_www" {
  domain   = "theyvoteforyou.org"
  name     = "www.theyvoteforyou.org"
  type     = "CNAME"
  value    = "theyvoteforyou.org"
}

resource "cloudflare_record" "alt2_root" {
  domain   = "theyvoteforyou.com.au"
  name     = "theyvoteforyou.com.au"
  type     = "A"
  value    = "${aws_eip.theyvoteforyou.public_ip}"
}

resource "cloudflare_record" "alt2_www" {
  domain   = "theyvoteforyou.com.au"
  name     = "www.theyvoteforyou.com.au"
  type     = "CNAME"
  value    = "theyvoteforyou.com.au"
}
