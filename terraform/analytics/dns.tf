# The public name is proxied so that Cloudflare caches the tracking script and
# absorbs abuse. Umami reads the visitor's address from CF-Connecting-IP, which
# only arrives on proxied traffic (see CLIENT_IP_HEADER in the umami role).
resource "cloudflare_record" "root" {
  zone_id = var.zone_id
  name    = "analytics.oaf.org.au"
  type    = "A"
  value   = aws_eip.main.public_ip
  proxied = true
}

# Ansible and ssh need to reach the origin directly, so keep an unproxied name
# pointing at the elastic IP. This is the srv.theyvoteforyou.org.au pattern and
# it is the name that goes in inventory/ec2-hosts.
resource "cloudflare_record" "non_proxy_root" {
  zone_id = var.zone_id
  name    = "srv.analytics.oaf.org.au"
  type    = "A"
  value   = aws_eip.main.public_ip
  proxied = false
}
