# A records
resource "cloudflare_record" "rtk_root" {
  domain = "righttoknow.org.au"
  name   = "righttoknow.org.au"
  type   = "A"
  value  = "${aws_eip.righttoknow.public_ip}"
}

# CNAME records
resource "cloudflare_record" "rtk_www" {
  domain = "righttoknow.org.au"
  name   = "www.righttoknow.org.au"
  type   = "CNAME"
  value  = "righttoknow.org.au"
}

resource "cloudflare_record" "rtk_test" {
  domain = "righttoknow.org.au"
  name   = "test.righttoknow.org.au"
  type   = "CNAME"
  value  = "righttoknow.org.au"
}

resource "cloudflare_record" "rtk_www_test" {
  domain = "righttoknow.org.au"
  name   = "www.test.righttoknow.org.au"
  type   = "CNAME"
  value  = "righttoknow.org.au"
}

# MX records
resource "cloudflare_record" "rtk_mx1" {
  domain   = "righttoknow.org.au"
  name     = "righttoknow.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "rtk_mx2" {
  domain   = "righttoknow.org.au"
  name     = "righttoknow.org.au"
  type     = "MX"
  priority = 20
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "rtk_mx3" {
  domain   = "righttoknow.org.au"
  name     = "righttoknow.org.au"
  type     = "MX"
  priority = 20
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "rtk_mx4" {
  domain   = "righttoknow.org.au"
  name     = "righttoknow.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "rtk_mx5" {
  domain   = "righttoknow.org.au"
  name     = "righttoknow.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx3.googlemail.com"
}

# TODO Check how this record is being used
resource "cloudflare_record" "rtk_server" {
  domain   = "righttoknow.org.au"
  name     = "server.righttoknow.org.au"
  type     = "MX"
  priority = 10
  value    = "righttoknow.org.au"
}

# TXT records
resource "cloudflare_record" "rtk_spf" {
  domain = "righttoknow.org.au"
  name   = "righttoknow.org.au"
  type   = "TXT"
  value  = "v=spf1 a include:_spf.google.com ~all"
}

resource "cloudflare_record" "rtk_google_site_verification" {
  domain = "righttoknow.org.au"
  name   = "righttoknow.org.au"
  type   = "TXT"
  value  = "google-site-verification=CPi5guMn0IiJjjYusPOb3ziStX_vKDqyk-cs0cLZvHc"
}

#Front DNS records
resource "cloudflare_record" "oaf_rtk_front_mx" {
  domain = "righttoknow.org.au"
  name = "front-mail.righttoknow.org.au"
  type = "MX"
  priority = 100
  value = "mx.sendgrid.net"
}

resource "cloudflare_record" "oaf_rtk_front_spf" {
  domain = "righttoknow.org.au"
  name   = "front-mail.righttoknow.org.au"
  type   = "TXT"
  value  = "v=spf1 a include:sendgrid.net ~all"
}

resource "cloudflare_record" "oaf_rtk_front_domainkey" {
  domain = "righttoknow.org.au"
  name   = "m1._domainkey.righttoknow.org.au"
  type   = "TXT"
  value  = "k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4PZZJiwMfMB/CuIZ9yAtNEGzfKzQ7WC7hfGg8UyavtYlDDBgSP6P1AiTBTMzTQbLChvf+Ef5CK46w+RwmgWpL38sxRwjahk45aQxoMOk2FJm7iHnP6zAGUnqAiL8iCdTjn5sp/txNf22bXrx3YS54ePBrfZQxOvkOvE24XZKXXwIDAQAB"
}
