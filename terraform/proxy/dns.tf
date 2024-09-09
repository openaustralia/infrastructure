resource "cloudflare_record" "au_proxy" {
  zone_id = var.zone_id
  name    = "au.proxy.oaf.org.au"
  type    = "A"
  value   = aws_eip.au_proxy.public_ip
}
