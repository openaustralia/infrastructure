# For mastodon hosting

resource "cloudflare_record" "social" {
  zone_id = var.oaf_org_au_zone_id
  name    = "social.oaf.org.au"
  type    = "CNAME"
  value   = "vip.masto.host"
}

moved {
  from = module.oaf.cloudflare_record.social
  to   = cloudflare_record.social
}
