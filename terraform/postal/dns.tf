# DNS for the Postal mail server (https://docs.postalserver.io/getting-started/dns-configuration)
#
# These are the per-server records. Each sending domain (planningalerts.org.au,
# theyvoteforyou.org.au, etc.) additionally needs its own SPF include and a
# per-domain DKIM record, which live in that service's own dns.tf.

# A records

resource "cloudflare_record" "a" {
  zone_id = var.zone_id
  name    = "postal.oaf.org.au"
  type    = "A"
  value   = linode_instance.main.ip_address
}

resource "cloudflare_record" "rp_a" {
  zone_id = var.zone_id
  name    = "rp.postal.oaf.org.au"
  type    = "A"
  value   = linode_instance.main.ip_address
}

# Exists so click/open tracking could be turned on later. We deliberately
# leave tracking disabled in Postal itself.
resource "cloudflare_record" "track_a" {
  zone_id = var.zone_id
  name    = "track.postal.oaf.org.au"
  type    = "A"
  value   = linode_instance.main.ip_address
}

# AAAA records

resource "cloudflare_record" "aaaa" {
  zone_id = var.zone_id
  name    = "postal.oaf.org.au"
  type    = "AAAA"
  value   = cidrhost(linode_instance.main.ipv6, 0)
}

resource "cloudflare_record" "rp_aaaa" {
  zone_id = var.zone_id
  name    = "rp.postal.oaf.org.au"
  type    = "AAAA"
  value   = cidrhost(linode_instance.main.ipv6, 0)
}

# MX records

# The return-path domain is the default MAIL FROM / bounce domain for all
# mail Postal sends, so remote MTAs deliver bounces here on port 25
resource "cloudflare_record" "rp_mx" {
  zone_id  = var.zone_id
  name     = "rp.postal.oaf.org.au"
  type     = "MX"
  priority = 10
  value    = "postal.oaf.org.au"
}

# Inbound mail routed to Postal "routes" (forwarding to HTTP endpoints etc.)
resource "cloudflare_record" "routes_mx" {
  zone_id  = var.zone_id
  name     = "routes.postal.oaf.org.au"
  type     = "MX"
  priority = 10
  value    = "postal.oaf.org.au"
}

# TXT records

resource "cloudflare_record" "spf" {
  zone_id = var.zone_id
  name    = "postal.oaf.org.au"
  type    = "TXT"
  value   = "v=spf1 a -all"
}

# The include referenced by every sending domain's SPF record. Future IP
# changes only need this one record updated.
resource "cloudflare_record" "spf_include" {
  zone_id = var.zone_id
  name    = "spf.postal.oaf.org.au"
  type    = "TXT"
  value   = "v=spf1 ip4:${linode_instance.main.ip_address} ip6:${cidrhost(linode_instance.main.ipv6, 0)} -all"
}

resource "cloudflare_record" "rp_spf" {
  zone_id = var.zone_id
  name    = "rp.postal.oaf.org.au"
  type    = "TXT"
  value   = "v=spf1 a mx include:spf.postal.oaf.org.au -all"
}

# DKIM for the return-path domain, signed with the installation's signing.key.
# The value is the p= record printed by `postal default-dkim-record`, only
# known once the signing key exists, hence the empty-string guard.
resource "cloudflare_record" "rp_dkim" {
  count   = var.return_path_dkim_record == "" ? 0 : 1
  zone_id = var.zone_id
  name    = "postal._domainkey.rp.postal.oaf.org.au"
  type    = "TXT"
  value   = var.return_path_dkim_record
}
