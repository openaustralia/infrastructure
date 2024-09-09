terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4.0"
    }
  }
}

# For mastodon hosting

resource "cloudflare_record" "root" {
  zone_id = var.zone_id
  name    = "social.oaf.org.au"
  type    = "CNAME"
  value   = "vip.masto.host"
}

moved {
  from = cloudflare_record.social
  to   = cloudflare_record.root
}
