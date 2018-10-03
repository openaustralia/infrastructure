# A records
resource "cloudflare_record" "morph_root" {
  domain = "morph.io"
  name   = "morph.io"
  type   = "A"
  value  = "${var.morph_ipv4}"
}

# CNAME records
resource "cloudflare_record" "morph_www" {
  domain = "morph.io"
  name   = "www.morph.io"
  type   = "CNAME"
  value  = "morph.io"
}

resource "cloudflare_record" "morph_api" {
  domain = "morph.io"
  name   = "api.morph.io"
  type   = "CNAME"
  value  = "morph.io"
}

resource "cloudflare_record" "morph_discuss" {
  domain = "morph.io"
  name   = "discuss.morph.io"
  type   = "CNAME"
  value  = "morph.io"
}

resource "cloudflare_record" "morph_faye" {
  domain = "morph.io"
  name   = "faye.morph.io"
  type   = "CNAME"
  value  = "morph.io"
}

resource "cloudflare_record" "morph_help" {
  domain = "morph.io"
  name   = "help.morph.io"
  type   = "CNAME"
  value  = "morph.io"
}

resource "cloudflare_record" "morph_email" {
  domain = "morph.io"
  name   = "email.morph.io"
  type   = "CNAME"
  value  = "cuttlefish.io"
}

resource "cloudflare_record" "morph_email2" {
  domain = "morph.io"
  name   = "email2.morph.io"
  type   = "CNAME"
  value  = "cuttlefish.oaf.org.au"
}

# MX records
resource "cloudflare_record" "morph_mx1" {
  domain   = "morph.io"
  name     = "morph.io"
  type     = "MX"
  priority = 10
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "morph_mx2" {
  domain   = "morph.io"
  name     = "morph.io"
  type     = "MX"
  priority = 20
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "morph_mx3" {
  domain   = "morph.io"
  name     = "morph.io"
  type     = "MX"
  priority = 20
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "morph_mx4" {
  domain   = "morph.io"
  name     = "morph.io"
  type     = "MX"
  priority = 30
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "morph_mx5" {
  domain   = "morph.io"
  name     = "morph.io"
  type     = "MX"
  priority = 30
  value    = "aspmx3.googlemail.com"
}

# TXT records
resource "cloudflare_record" "morph_spf" {
  domain = "morph.io"
  name   = "morph.io"
  type   = "TXT"
  value  = "v=spf1 include:_spf.google.com -all"
}

resource "cloudflare_record" "morph_google_site_verification" {
  domain = "morph.io"
  name   = "morph.io"
  type   = "TXT"
  value  = "google-site-verification=in8HCE8-6fspAg-ak4TpaWthQ2ix6Ne8sBIzAPwFdDc"
}

resource "cloudflare_record" "morph_domainkey" {
  domain = "morph.io"
  name   = "cuttlefish._domainkey.morph.io"
  type   = "TXT"
  value  = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyo1f2xqD/AeDj2YnQC/xsksEqZ2mxW5hHiRi1jFX7pR0jb1Tf7LVAgj7rtWBxQvjo3xIOZ2wy5z+1hjlN1NDni023O6bFXNY7d/kSqo2E+y8pzReq5qZJu46Ozz88LedU+4/DEnNqSPFbnDjIM5VMEDcw4KhacCDKdNg83yDkKV3x5ugz5K7gRAorYyIxRL4ZQJP0fOWS7hGpMKYoyJ8hRFdtGAx9yS2wySmUdpKQheQJV63iuSZ4aNcYuWuLULGkhMU8usJVMtwuptEwRHF6+JoOLo+alvya3wgaa0L1sopFKOSYrUGs7zOnIXBGVGbNkg15Ik+1PFGKg05LixJ/QIDAQAB"
}

# CAA records

# TODO: Add CAA record as soon as a new version of the Cloudflare terraform
# provider is released. See https://github.com/terraform-providers/terraform-provider-cloudflare/pull/29

# The CAA record should look like:
# morph.io.		60	IN	CAA	128 issue "letsencrypt.org"

# Front DNS records
resource "cloudflare_record" "oaf_morph_front_mx" {
  domain = "morph.io"
  name = "front-mail.morph.io"
  type = "MX"
  priority = 100
  value = "mx.sendgrid.net"
}

resource "cloudflare_record" "oaf_morph_front_mx" {
  domain = "morph.io"
  name   = "front-mail.morph.io"
  type   = "TXT"
  value  = "v=spf1 a include:sendgrid.net ~all"
}

resource "cloudflare_record" "oaf_morph_front_mx" {
  domain = "morph.io"
  name   = "front-mail.morph.io"
  type   = "TXT"
  value  = "k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4PZZJiwMfMB/CuIZ9yAtNEGzfKzQ7WC7hfGg8UyavtYlDDBgSP6P1AiTBTMzTQbLChvf+Ef5CK46w+RwmgWpL38sxRwjahk45aQxoMOk2FJm7iHnP6zAGUnqAiL8iCdTjn5sp/txNf22bXrx3YS54ePBrfZQxOvkOvE24XZKXXwIDAQAB"
}
