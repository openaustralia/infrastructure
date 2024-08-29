# A records
resource "cloudflare_record" "root" {
  zone_id = var.morph_io_zone_id
  name    = "morph.io"
  type    = "A"
  value   = var.ipv4
}

moved {
  from = cloudflare_record.morph_root
  to   = cloudflare_record.root
}

# CNAME records
resource "cloudflare_record" "www" {
  zone_id = var.morph_io_zone_id
  name    = "www.morph.io"
  type    = "CNAME"
  value   = "morph.io"
}

moved {
  from = cloudflare_record.morph_www
  to   = cloudflare_record.www
}

resource "cloudflare_record" "api" {
  zone_id = var.morph_io_zone_id
  name    = "api.morph.io"
  type    = "CNAME"
  value   = "morph.io"
}

moved {
  from = cloudflare_record.morph_api
  to   = cloudflare_record.api
}

resource "cloudflare_record" "discuss" {
  zone_id = var.morph_io_zone_id
  name    = "discuss.morph.io"
  type    = "CNAME"
  value   = "morph.io"
}

moved {
  from = cloudflare_record.morph_discuss
  to   = cloudflare_record.discuss
}

resource "cloudflare_record" "faye" {
  zone_id = var.morph_io_zone_id
  name    = "faye.morph.io"
  type    = "CNAME"
  value   = "morph.io"
}

moved {
  from = cloudflare_record.morph_faye
  to   = cloudflare_record.faye
}

resource "cloudflare_record" "help" {
  zone_id = var.morph_io_zone_id
  name    = "help.morph.io"
  type    = "CNAME"
  value   = "morph.io"
}

moved {
  from = cloudflare_record.morph_help
  to   = cloudflare_record.help
}

# TODO: Can we get rid of this now?
resource "cloudflare_record" "email" {
  zone_id = var.morph_io_zone_id
  name    = "email.morph.io"
  type    = "CNAME"
  value   = "cuttlefish.io"
}

moved {
  from = cloudflare_record.morph_email
  to   = cloudflare_record.email
}

resource "cloudflare_record" "email2" {
  zone_id = var.morph_io_zone_id
  name    = "email2.morph.io"
  type    = "CNAME"
  value   = "cuttlefish.oaf.org.au"
}

moved {
  from = cloudflare_record.morph_email2
  to   = cloudflare_record.email2
}

# MX records
resource "cloudflare_record" "mx1" {
  zone_id  = var.morph_io_zone_id
  name     = "morph.io"
  type     = "MX"
  priority = 10
  value    = "aspmx.l.google.com"
}

moved {
  from = cloudflare_record.morph_mx1
  to   = cloudflare_record.mx1
}

resource "cloudflare_record" "mx2" {
  zone_id  = var.morph_io_zone_id
  name     = "morph.io"
  type     = "MX"
  priority = 20
  value    = "alt1.aspmx.l.google.com"
}

moved {
  from = cloudflare_record.morph_mx2
  to   = cloudflare_record.mx2
}

resource "cloudflare_record" "mx3" {
  zone_id  = var.morph_io_zone_id
  name     = "morph.io"
  type     = "MX"
  priority = 20
  value    = "alt2.aspmx.l.google.com"
}

moved {
  from = cloudflare_record.morph_mx3
  to   = cloudflare_record.mx3
}

resource "cloudflare_record" "mx4" {
  zone_id  = var.morph_io_zone_id
  name     = "morph.io"
  type     = "MX"
  priority = 30
  value    = "aspmx2.googlemail.com"
}

moved {
  from = cloudflare_record.morph_mx4
  to   = cloudflare_record.mx4
}

resource "cloudflare_record" "mx5" {
  zone_id  = var.morph_io_zone_id
  name     = "morph.io"
  type     = "MX"
  priority = 30
  value    = "aspmx3.googlemail.com"
}

moved {
  from = cloudflare_record.morph_mx5
  to   = cloudflare_record.mx5
}

# TXT records
resource "cloudflare_record" "spf" {
  zone_id = var.morph_io_zone_id
  name    = "morph.io"
  type    = "TXT"
  value   = "v=spf1 include:_spf.google.com -all"
}

moved {
  from = cloudflare_record.morph_spf
  to   = cloudflare_record.spf
}

resource "cloudflare_record" "google_site_verification" {
  zone_id = var.morph_io_zone_id
  name    = "morph.io"
  type    = "TXT"
  value   = "google-site-verification=in8HCE8-6fspAg-ak4TpaWthQ2ix6Ne8sBIzAPwFdDc"
}

moved {
  from = cloudflare_record.morph_google_site_verification
  to   = cloudflare_record.google_site_verification
}

# TODO: Remove this once the one below is up and running
resource "cloudflare_record" "domainkey" {
  zone_id = var.morph_io_zone_id
  name    = "cuttlefish._domainkey.morph.io"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyo1f2xqD/AeDj2YnQC/xsksEqZ2mxW5hHiRi1jFX7pR0jb1Tf7LVAgj7rtWBxQvjo3xIOZ2wy5z+1hjlN1NDni023O6bFXNY7d/kSqo2E+y8pzReq5qZJu46Ozz88LedU+4/DEnNqSPFbnDjIM5VMEDcw4KhacCDKdNg83yDkKV3x5ugz5K7gRAorYyIxRL4ZQJP0fOWS7hGpMKYoyJ8hRFdtGAx9yS2wySmUdpKQheQJV63iuSZ4aNcYuWuLULGkhMU8usJVMtwuptEwRHF6+JoOLo+alvya3wgaa0L1sopFKOSYrUGs7zOnIXBGVGbNkg15Ik+1PFGKg05LixJ/QIDAQAB"
}

moved {
  from = cloudflare_record.morph_domainkey
  to   = cloudflare_record.domainkey
}

resource "cloudflare_record" "domainkey2" {
  zone_id = var.morph_io_zone_id
  name    = "morph_2.cuttlefish._domainkey.morph.io"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyo1f2xqD/AeDj2YnQC/xsksEqZ2mxW5hHiRi1jFX7pR0jb1Tf7LVAgj7rtWBxQvjo3xIOZ2wy5z+1hjlN1NDni023O6bFXNY7d/kSqo2E+y8pzReq5qZJu46Ozz88LedU+4/DEnNqSPFbnDjIM5VMEDcw4KhacCDKdNg83yDkKV3x5ugz5K7gRAorYyIxRL4ZQJP0fOWS7hGpMKYoyJ8hRFdtGAx9yS2wySmUdpKQheQJV63iuSZ4aNcYuWuLULGkhMU8usJVMtwuptEwRHF6+JoOLo+alvya3wgaa0L1sopFKOSYrUGs7zOnIXBGVGbNkg15Ik+1PFGKg05LixJ/QIDAQAB"
}

moved {
  from = cloudflare_record.morph_domainkey2
  to   = cloudflare_record.domainkey2
}

resource "cloudflare_record" "google_domainkey" {
  zone_id = var.morph_io_zone_id
  name    = "google._domainkey.morph.io"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuVyV09pmp6w9YCOWQ9+2p/xe6w7mbZYgg0v4d+51GSoVrQNwp5RERtg76xhl3pbHSLVmtQyfdavLZN/r38/b3NS7E9AsD3dOUIa1iy60YklKVgcWr5eMIviL3E9FXqyQBULoffTWDj69Q/uVsmZmD1VFDICzEctlgKLs9cdtky4kssQQOfJ2KVMfa/GNCorF628jeHiqB6A2UsP/RQ40VVDunDatWO/0mmwHSRJSB61RSro2dYqzo8lzKOBWxnZDxkDO13Dg41VAlOReu4qDRn1MbCj3T79Ur1I6GJj09Em/va/VD4qKJPPt+lW7fKPqVlQ1RqEtSJUGMmiSEKlbYwIDAQAB"
}

moved {
  from = cloudflare_record.morph_google_domainkey
  to   = cloudflare_record.google_domainkey
}

# For the time being we're just using DMARC records to get some data on what's
# happening with email that we're sending (and whether anyone else is impersonating
# us).
# We're using a free service provided by https://dmarc.postmarkapp.com/
# This generates a weekly DMARC report which gets sent by email on Monday mornings
# Report goes to webmaster@morph.io
resource "cloudflare_record" "dmarc" {
  zone_id = var.morph_io_zone_id
  name    = "_dmarc.morph.io"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+yuyhziqptlw@dmarc.postmarkapp.com; sp=none; aspf=r;"
}

moved {
  from = cloudflare_record.morph_dmarc
  to   = cloudflare_record.dmarc
}

# CAA records

# TODO: Add CAA record as soon as a new version of the Cloudflare terraform
# provider is released. See https://github.com/terraform-providers/terraform-provider-cloudflare/pull/29

# The CAA record should look like:
# morph.io.		60	IN	CAA	128 issue "letsencrypt.org"
