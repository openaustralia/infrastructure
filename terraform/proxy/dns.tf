resource "cloudflare_record" "root" {
  zone_id = var.zone_id
  name    = "au.proxy.oaf.org.au"
  type    = "A"
  value   = aws_eip.main.public_ip
}
