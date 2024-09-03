# A records
resource "cloudflare_record" "root" {
  zone_id = var.opengovernment_org_au_zone_id
  name    = "opengovernment.org.au"
  type    = "A"
  value   = aws_eip.main.public_ip
}

# CNAME records
resource "cloudflare_record" "www" {
  zone_id = var.opengovernment_org_au_zone_id
  name    = "www.opengovernment.org.au"
  type    = "CNAME"
  value   = "opengovernment.org.au"
}

# MX records

# We can now use a single MX record for Google workspace
resource "cloudflare_record" "mx" {
  zone_id  = var.opengovernment_org_au_zone_id
  name     = "opengovernment.org.au"
  type     = "MX"
  priority = 1
  value    = "smtp.google.com"
}

# TXT records
resource "cloudflare_record" "spf" {
  zone_id = var.opengovernment_org_au_zone_id
  name    = "opengovernment.org.au"
  type    = "TXT"
  value   = "v=spf1 include:_spf.google.com ip4:${var.cuttlefish_ipv4} ~all"
}

resource "cloudflare_record" "google_site_verification" {
  zone_id = var.opengovernment_org_au_zone_id
  name    = "opengovernment.org.au"
  type    = "TXT"
  value   = "google-site-verification=ajKozOG3pB6RVV0hiXG-wXGbzfHdteQseLQqGwngm4w"
}

# TODO: Remove this once the one below is up and running
resource "cloudflare_record" "domainkey" {
  zone_id = var.opengovernment_org_au_zone_id
  name    = "cuttlefish._domainkey.opengovernment.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxE7nVpdr3lqufGDHC6r6bdP0JphHwkapFlORsC3LzRf0IgnuGOylxormE11nJtKRFawFyhDtNaguyIahKljjGtwAII3qWaVuxQASPOpVce6FTfR51Cpfah7OE3qN9CjoHZWhun3pj7G1zGdwcaTWHnK4qyudT7fM1c00jwHhSE9L9f6c7MXCiA/YGcgK+UAHy/zRTpMN1pSjrIJf9Z+mDU2RaC5tMGbfUw1307qzE8OaChhskrPdUo7nZvswK0G63dJCatPWtjuKG1zGVQcS61MwK/wyqikWBzCYPvDV9lx7/Occ1jYGh12HzrStgsTfD1Lr+tvNkAB1mg1uTfnmlwIDAQAB"
}

resource "cloudflare_record" "domainkey2" {
  zone_id = var.opengovernment_org_au_zone_id
  name    = "opengovernment_org_au_26.cuttlefish._domainkey.opengovernment.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxE7nVpdr3lqufGDHC6r6bdP0JphHwkapFlORsC3LzRf0IgnuGOylxormE11nJtKRFawFyhDtNaguyIahKljjGtwAII3qWaVuxQASPOpVce6FTfR51Cpfah7OE3qN9CjoHZWhun3pj7G1zGdwcaTWHnK4qyudT7fM1c00jwHhSE9L9f6c7MXCiA/YGcgK+UAHy/zRTpMN1pSjrIJf9Z+mDU2RaC5tMGbfUw1307qzE8OaChhskrPdUo7nZvswK0G63dJCatPWtjuKG1zGVQcS61MwK/wyqikWBzCYPvDV9lx7/Occ1jYGh12HzrStgsTfD1Lr+tvNkAB1mg1uTfnmlwIDAQAB"
}

# For the time being we're just using DMARC records to get some data on what's
# happening with email that we're sending (and whether anyone else is impersonating
# us).
# We're using a free service provided by https://dmarc.postmarkapp.com/
# This generates a weekly DMARC report which gets sent by email on Monday mornings
# Report goes to webmaster@opengovernment.org.au
resource "cloudflare_record" "dmarc" {
  zone_id = var.opengovernment_org_au_zone_id
  name    = "_dmarc.opengovernment.org.au"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+hm1wga71eti@dmarc.postmarkapp.com; sp=none; aspf=r;"
}
