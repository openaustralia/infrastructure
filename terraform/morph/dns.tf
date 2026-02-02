resource "cloudflare_zone" "main" {
  account_id = var.cloudflare_account_id
  plan       = "business"
  zone       = "morph.io"
}

# A records
resource "cloudflare_record" "root" {
  zone_id = cloudflare_zone.main.id
  name    = "morph.io"
  type    = "A"
  value   = linode_instance.main.ip_address
}

# CNAME records
resource "cloudflare_record" "www" {
  zone_id = cloudflare_zone.main.id
  name    = "www.morph.io"
  type    = "CNAME"
  value   = "morph.io"
}

resource "cloudflare_record" "api" {
  zone_id = cloudflare_zone.main.id
  name    = "api.morph.io"
  type    = "CNAME"
  value   = "morph.io"
}

resource "cloudflare_record" "discuss" {
  zone_id = cloudflare_zone.main.id
  name    = "discuss.morph.io"
  type    = "CNAME"
  value   = "morph.io"
}

resource "cloudflare_record" "faye" {
  zone_id = cloudflare_zone.main.id
  name    = "faye.morph.io"
  type    = "CNAME"
  value   = "morph.io"
}

resource "cloudflare_record" "help" {
  zone_id = cloudflare_zone.main.id
  name    = "help.morph.io"
  type    = "CNAME"
  value   = "morph.io"
}

# TODO: Can we get rid of this now?
resource "cloudflare_record" "email" {
  zone_id = cloudflare_zone.main.id
  name    = "email.morph.io"
  type    = "CNAME"
  value   = "cuttlefish.io"
}

resource "cloudflare_record" "email2" {
  zone_id = cloudflare_zone.main.id
  name    = "email2.morph.io"
  type    = "CNAME"
  value   = "cuttlefish.oaf.org.au"
}

# MX records

# We can now use a single MX record for Google workspace
resource "cloudflare_record" "mx" {
  zone_id  = cloudflare_zone.main.id
  name     = "morph.io"
  type     = "MX"
  priority = 1
  value    = "smtp.google.com"
}

# TXT records
resource "cloudflare_record" "spf" {
  zone_id = cloudflare_zone.main.id
  name    = "morph.io"
  type    = "TXT"
  value   = "v=spf1 include:_spf1.oaf.org.au include:_spf.google.com -all"
}

resource "cloudflare_record" "google_site_verification" {
  zone_id = cloudflare_zone.main.id
  name    = "morph.io"
  type    = "TXT"
  value   = "google-site-verification=in8HCE8-6fspAg-ak4TpaWthQ2ix6Ne8sBIzAPwFdDc"
}

# TODO: Remove this once the one below is up and running
resource "cloudflare_record" "domainkey" {
  zone_id = cloudflare_zone.main.id
  name    = "cuttlefish._domainkey.morph.io"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyo1f2xqD/AeDj2YnQC/xsksEqZ2mxW5hHiRi1jFX7pR0jb1Tf7LVAgj7rtWBxQvjo3xIOZ2wy5z+1hjlN1NDni023O6bFXNY7d/kSqo2E+y8pzReq5qZJu46Ozz88LedU+4/DEnNqSPFbnDjIM5VMEDcw4KhacCDKdNg83yDkKV3x5ugz5K7gRAorYyIxRL4ZQJP0fOWS7hGpMKYoyJ8hRFdtGAx9yS2wySmUdpKQheQJV63iuSZ4aNcYuWuLULGkhMU8usJVMtwuptEwRHF6+JoOLo+alvya3wgaa0L1sopFKOSYrUGs7zOnIXBGVGbNkg15Ik+1PFGKg05LixJ/QIDAQAB"
}

resource "cloudflare_record" "domainkey2" {
  zone_id = cloudflare_zone.main.id
  name    = "morph_2.cuttlefish._domainkey.morph.io"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyo1f2xqD/AeDj2YnQC/xsksEqZ2mxW5hHiRi1jFX7pR0jb1Tf7LVAgj7rtWBxQvjo3xIOZ2wy5z+1hjlN1NDni023O6bFXNY7d/kSqo2E+y8pzReq5qZJu46Ozz88LedU+4/DEnNqSPFbnDjIM5VMEDcw4KhacCDKdNg83yDkKV3x5ugz5K7gRAorYyIxRL4ZQJP0fOWS7hGpMKYoyJ8hRFdtGAx9yS2wySmUdpKQheQJV63iuSZ4aNcYuWuLULGkhMU8usJVMtwuptEwRHF6+JoOLo+alvya3wgaa0L1sopFKOSYrUGs7zOnIXBGVGbNkg15Ik+1PFGKg05LixJ/QIDAQAB"
}

resource "cloudflare_record" "google_domainkey" {
  zone_id = cloudflare_zone.main.id
  name    = "google._domainkey.morph.io"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuVyV09pmp6w9YCOWQ9+2p/xe6w7mbZYgg0v4d+51GSoVrQNwp5RERtg76xhl3pbHSLVmtQyfdavLZN/r38/b3NS7E9AsD3dOUIa1iy60YklKVgcWr5eMIviL3E9FXqyQBULoffTWDj69Q/uVsmZmD1VFDICzEctlgKLs9cdtky4kssQQOfJ2KVMfa/GNCorF628jeHiqB6A2UsP/RQ40VVDunDatWO/0mmwHSRJSB61RSro2dYqzo8lzKOBWxnZDxkDO13Dg41VAlOReu4qDRn1MbCj3T79Ur1I6GJj09Em/va/VD4qKJPPt+lW7fKPqVlQ1RqEtSJUGMmiSEKlbYwIDAQAB"
}

# DMARC record for email authentication and reporting
# Reports are sent to both Suped (for monitoring) and Postmark (legacy weekly reports)
# Suped provides ongoing monitoring and analysis
# Postmark generates a weekly DMARC report which gets sent by email on Monday mornings
# Report goes to webmaster@morph.io
resource "cloudflare_record" "dmarc" {
  zone_id = cloudflare_zone.main.id
  name    = "_dmarc.morph.io"
  type    = "TXT"
  value   = "v=DMARC1; p=none; rua=mailto:dmarc.dpdztvxlz24gajbdj6yz@mail.suped.com,mailto:re+yuyhziqptlw@dmarc.postmarkapp.com; ruf=; pct=100; adkim=r; aspf=r; fo=1; ri=86400"
}

# CAA records

# TODO: Add CAA record as soon as a new version of the Cloudflare terraform
# provider is released. See https://github.com/terraform-providers/terraform-provider-cloudflare/pull/29

# The CAA record should look like:
# morph.io.		60	IN	CAA	128 issue "letsencrypt.org"
