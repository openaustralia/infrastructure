# For mastodon hosting

resource "cloudflare_record" "social" {
  zone_id = cloudflare_zone.oaf_org_au.id
  name    = "social.oaf.org.au"
  type    = "CNAME"
  value   = "vip.masto.host"
}
