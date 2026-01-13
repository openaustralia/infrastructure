resource "cloudflare_zone" "main" {
  account_id = var.cloudflare_account_id
  plan       = "free"
  zone       = "electionleaflets.org.au"
}

# A records
resource "cloudflare_record" "root" {
  zone_id = cloudflare_zone.main.id
  name    = "electionleaflets.org.au"
  comment = "Used to create Redirect Rule"
  proxied = true
  type    = "A"
  value   = "192.0.2.1" # Cloudflare
}

# TODO: Can we extract the creation of several cnames into a simple module?
# CNAME records
resource "cloudflare_record" "www" {
  zone_id = cloudflare_zone.main.id
  name    = "www.electionleaflets.org.au"
  proxied = true
  type    = "CNAME"
  value   = "electionleaflets.org.au"
}
