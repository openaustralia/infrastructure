# A records
resource "cloudflare_record" "opengovernment_root" {
  domain = "opengovernment.org.au"
  name   = "opengovernment.org.au"
  type   = "A"
  value  = "${aws_eip.opengovernment.public_ip}"
}

# CNAME records
resource "cloudflare_record" "opengovernment_www" {
  domain = "opengovernment.org.au"
  name   = "www.opengovernment.org.au"
  type   = "CNAME"
  value  = "opengovernment.org.au"
}

# MX records
resource "cloudflare_record" "opengovernment_mx1" {
  domain   = "opengovernment.org.au"
  name     = "opengovernment.org.au"
  type     = "MX"
  priority = 1
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "opengovernment_mx2" {
  domain   = "opengovernment.org.au"
  name     = "opengovernment.org.au"
  type     = "MX"
  priority = 5
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "opengovernment_mx3" {
  domain   = "opengovernment.org.au"
  name     = "opengovernment.org.au"
  type     = "MX"
  priority = 5
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "opengovernment_mx4" {
  domain   = "opengovernment.org.au"
  name     = "opengovernment.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "opengovernment_mx5" {
  domain   = "opengovernment.org.au"
  name     = "opengovernment.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx3.googlemail.com"
}

# TXT records
resource "cloudflare_record" "opengovernment_spf" {
  domain = "opengovernment.org.au"
  name   = "opengovernment.org.au"
  type   = "TXT"
  value  = "v=spf1 include:_spf.google.com ip4:${var.cuttlefish_ipv4} ~all"
}

resource "cloudflare_record" "opengovernment_google_site_verification" {
  domain = "opengovernment.org.au"
  name   = "opengovernment.org.au"
  type   = "TXT"
  value  = "google-site-verification=fuS0OoXUv8rGwkULIl8SJw3_lLJHDfKnEWPw27gVHCE"
}

resource "cloudflare_record" "opengovernment_domainkey" {
  domain = "opengovernment.org.au"
  name   = "cuttlefish._domainkey.opengovernment.org.au"
  type   = "TXT"
  value  = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxE7nVpdr3lqufGDHC6r6bdP0JphHwkapFlORsC3LzRf0IgnuGOylxormE11nJtKRFawFyhDtNaguyIahKljjGtwAII3qWaVuxQASPOpVce6FTfR51Cpfah7OE3qN9CjoHZWhun3pj7G1zGdwcaTWHnK4qyudT7fM1c00jwHhSE9L9f6c7MXCiA/YGcgK+UAHy/zRTpMN1pSjrIJf9Z+mDU2RaC5tMGbfUw1307qzE8OaChhskrPdUo7nZvswK0G63dJCatPWtjuKG1zGVQcS61MwK/wyqikWBzCYPvDV9lx7/Occ1jYGh12HzrStgsTfD1Lr+tvNkAB1mg1uTfnmlwIDAQAB"
}
