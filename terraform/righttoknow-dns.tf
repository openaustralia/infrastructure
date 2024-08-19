variable "righttoknow_org_au_zone_id" {
  default = "44b07a3486191276e3e6b0919dd86fff"
}

# A records
resource "cloudflare_record" "rtk_root" {
  zone_id = var.righttoknow_org_au_zone_id
  name    = "righttoknow.org.au"
  type    = "A"
  value   = aws_eip.righttoknow.public_ip
}

# CNAME records
resource "cloudflare_record" "rtk_www" {
  zone_id = var.righttoknow_org_au_zone_id
  name    = "www.righttoknow.org.au"
  type    = "CNAME"
  value   = "righttoknow.org.au"
}

resource "cloudflare_record" "rtk_test" {
  zone_id = var.righttoknow_org_au_zone_id
  name    = "test.righttoknow.org.au"
  type    = "CNAME"
  value   = "righttoknow.org.au"
}

resource "cloudflare_record" "rtk_www_test" {
  zone_id = var.righttoknow_org_au_zone_id
  name    = "www.test.righttoknow.org.au"
  type    = "CNAME"
  value   = "righttoknow.org.au"
}

# MX records
resource "cloudflare_record" "rtk_mx1" {
  zone_id  = var.righttoknow_org_au_zone_id
  name     = "righttoknow.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "rtk_mx2" {
  zone_id  = var.righttoknow_org_au_zone_id
  name     = "righttoknow.org.au"
  type     = "MX"
  priority = 20
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "rtk_mx3" {
  zone_id  = var.righttoknow_org_au_zone_id
  name     = "righttoknow.org.au"
  type     = "MX"
  priority = 20
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "rtk_mx4" {
  zone_id  = var.righttoknow_org_au_zone_id
  name     = "righttoknow.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "rtk_mx5" {
  zone_id  = var.righttoknow_org_au_zone_id
  name     = "righttoknow.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx3.googlemail.com"
}

# TODO Check how this record is being used
resource "cloudflare_record" "rtk_server" {
  zone_id  = var.righttoknow_org_au_zone_id
  name     = "server.righttoknow.org.au"
  type     = "MX"
  priority = 10
  value    = "righttoknow.org.au"
}

# TXT records
resource "cloudflare_record" "rtk_spf" {
  zone_id = var.righttoknow_org_au_zone_id
  name    = "righttoknow.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:_spf.google.com ~all"
}

resource "cloudflare_record" "rtk_google_site_verification" {
  zone_id = var.righttoknow_org_au_zone_id
  name    = "righttoknow.org.au"
  type    = "TXT"
  value   = "google-site-verification=ci77kXOm4-lxR3Tc1D1FlTzz0J_GWQES2wU5kFMIR-w"
}

resource "cloudflare_record" "rtk_facebook_domain_verification" {
  zone_id = var.righttoknow_org_au_zone_id
  name    = "righttoknow.org.au"
  type    = "TXT"
  value   = "facebook-domain-verification=vtlcbmfm4mihp4wql58lwz3nbhc8bt"
}

# Note that this record comes from roles/internal/righttoknow/files/dkimkeys/default.txt which in turn is generated
# by hand (as part of a keypair) using opendkim
resource "cloudflare_record" "rtk_default_domainkey" {
  zone_id = var.righttoknow_org_au_zone_id
  name    = "default._domainkey.righttoknow.org.au"
  type    = "TXT"
  value   = "v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzWFLO143fpHeVU27EjmOsY4hpKtR+/PI+idJItMWiHSwjgcX21QYMbQjPcHfHFhsDbblBBQy/MtcTwynSYFp1SWkTI8EsHLS1+pp1HAI3wx7ZWLmwE6di+qRKu+3ooPFSIUbA+TvA7GJmHBfBf/ubASWff4t5ByZ9edZOA4lZ7pGdG7O0duH+/hhggH/LFMPX6a0CzyXYjsfTvtyYMJvvRsoepEs/QjtdBarZS2roR7qxZQhSRUlbZgSNAbyO0+3wJptpxvAXleSuOFoN5nHMV4LT+vuF0g+FDxIpbJu+bW08IKL1qMSH8Gtwd20Hy34h88IHPg8zx5FUoeeOS5W/wIDAQAB"
}

#Front DNS records
resource "cloudflare_record" "oaf_rtk_front_mx" {
  zone_id  = var.righttoknow_org_au_zone_id
  name     = "front-mail.righttoknow.org.au"
  type     = "MX"
  priority = 100
  value    = "mx.sendgrid.net"
}

resource "cloudflare_record" "oaf_rtk_front_spf" {
  zone_id = var.righttoknow_org_au_zone_id
  name    = "front-mail.righttoknow.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:sendgrid.net ~all"
}

resource "cloudflare_record" "oaf_rtk_front_domainkey" {
  zone_id = var.righttoknow_org_au_zone_id
  name    = "m1._domainkey.righttoknow.org.au"
  type    = "TXT"
  value   = "k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4PZZJiwMfMB/CuIZ9yAtNEGzfKzQ7WC7hfGg8UyavtYlDDBgSP6P1AiTBTMzTQbLChvf+Ef5CK46w+RwmgWpL38sxRwjahk45aQxoMOk2FJm7iHnP6zAGUnqAiL8iCdTjn5sp/txNf22bXrx3YS54ePBrfZQxOvkOvE24XZKXXwIDAQAB"
}
