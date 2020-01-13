variable "yinyo_io_zone_id" {
  default = "9734850222324fac212c52ba30615585"
}

# A records
resource "cloudflare_record" "yinyo_root1" {
  zone_id = var.yinyo_io_zone_id
  name    = "yinyo.io"
  type    = "A"
  value   = "185.199.108.153"
}

resource "cloudflare_record" "yinyo_root2" {
  zone_id = var.yinyo_io_zone_id
  name    = "yinyo.io"
  type    = "A"
  value   = "185.199.109.153"
}

resource "cloudflare_record" "yinyo_root3" {
  zone_id = var.yinyo_io_zone_id
  name    = "yinyo.io"
  type    = "A"
  value   = "185.199.110.153"
}

resource "cloudflare_record" "yinyo_root4" {
  zone_id = var.yinyo_io_zone_id
  name    = "yinyo.io"
  type    = "A"
  value   = "185.199.111.153"
}

# TXT records

resource "cloudflare_record" "google_verification" {
  zone_id = var.yinyo_io_zone_id
  name    = "yinyo.io"
  type    = "TXT"
  value   = "google-site-verification=oWOPVdzD5v7gzg8zcV-cPlkBr_tE5jAuu6jT5t2aksY"
}
