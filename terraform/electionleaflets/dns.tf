# A records
resource "cloudflare_record" "root" {
  zone_id = cloudflare_zone.main.id
  name    = "electionleaflets.org.au"
  type    = "A"
  value   = aws_eip.electionleaflets.public_ip
}

# TODO: Can we extract the creation of several cnames into a simple module?
# CNAME records
resource "cloudflare_record" "www" {
  zone_id = cloudflare_zone.main.id
  name    = "www.electionleaflets.org.au"
  type    = "CNAME"
  value   = "electionleaflets.org.au"
}
