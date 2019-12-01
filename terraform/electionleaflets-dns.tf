variable "electionleaflets_org_au_zone_id" {
  default = "4cd5afd47047e6a7e37563d013d431ae"
}

# A records
resource "cloudflare_record" "el_root" {
  zone_id = "${var.electionleaflets_org_au_zone_id}"
  name    = "electionleaflets.org.au"
  type    = "A"
  value   = "${aws_eip.electionleaflets.public_ip}"
}

# CNAME records
resource "cloudflare_record" "el_www" {
  zone_id = "${var.electionleaflets_org_au_zone_id}"
  name    = "www.electionleaflets.org.au"
  type    = "CNAME"
  value   = "electionleaflets.org.au"
}

resource "cloudflare_record" "el_test" {
  zone_id = "${var.electionleaflets_org_au_zone_id}"
  name    = "test.electionleaflets.org.au"
  type    = "CNAME"
  value   = "electionleaflets.org.au"
}

resource "cloudflare_record" "el_www_test" {
  zone_id = "${var.electionleaflets_org_au_zone_id}"
  name    = "www.test.electionleaflets.org.au"
  type    = "CNAME"
  value   = "electionleaflets.org.au"
}

resource "cloudflare_record" "el_federal2010" {
  zone_id = "${var.electionleaflets_org_au_zone_id}"
  name    = "federal2010.electionleaflets.org.au"
  type    = "CNAME"
  value   = "electionleaflets.org.au"
}

# TODO: Do we still need this?
resource "cloudflare_record" "el_google_domain_verification" {
  zone_id = "${var.electionleaflets_org_au_zone_id}"
  name    = "googleffffffffc7db8b0c.electionleaflets.org.au"
  type    = "CNAME"
  value   = "google.com"
}

# MX records
resource "cloudflare_record" "el_mx1" {
  zone_id  = "${var.electionleaflets_org_au_zone_id}"
  name     = "electionleaflets.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "el_mx2" {
  zone_id  = "${var.electionleaflets_org_au_zone_id}"
  name     = "electionleaflets.org.au"
  type     = "MX"
  priority = 20
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "el_mx3" {
  zone_id  = "${var.electionleaflets_org_au_zone_id}"
  name     = "electionleaflets.org.au"
  type     = "MX"
  priority = 20
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "el_mx4" {
  zone_id  = "${var.electionleaflets_org_au_zone_id}"
  name     = "electionleaflets.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "el_mx5" {
  zone_id  = "${var.electionleaflets_org_au_zone_id}"
  name     = "electionleaflets.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx3.googlemail.com"
}

resource "cloudflare_record" "el_mx6" {
  zone_id  = "${var.electionleaflets_org_au_zone_id}"
  name     = "electionleaflets.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx4.googlemail.com"
}

resource "cloudflare_record" "el_mx7" {
  zone_id  = "${var.electionleaflets_org_au_zone_id}"
  name     = "electionleaflets.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx5.googlemail.com"
}

# TXT records
resource "cloudflare_record" "el_spf" {
  zone_id = "${var.electionleaflets_org_au_zone_id}"
  name    = "electionleaflets.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:_spf.google.com ~all"
}

#Front DNS records
resource "cloudflare_record" "oaf_electionleaflets_front_mx" {
  zone_id  = "${var.electionleaflets_org_au_zone_id}"
  name     = "front-mail.electionleaflets.org.au"
  type     = "MX"
  priority = 100
  value    = "mx.sendgrid.net"
}

resource "cloudflare_record" "oaf_electionleaflets_front_spf" {
  zone_id = "${var.electionleaflets_org_au_zone_id}"
  name    = "front-mail.electionleaflets.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:sendgrid.net ~all"
}

resource "cloudflare_record" "oaf_electionleaflets_front_domainkey" {
  zone_id = "${var.electionleaflets_org_au_zone_id}"
  name    = "m1._domainkey.electionleaflets.org.au"
  type    = "TXT"
  value   = "k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4PZZJiwMfMB/CuIZ9yAtNEGzfKzQ7WC7hfGg8UyavtYlDDBgSP6P1AiTBTMzTQbLChvf+Ef5CK46w+RwmgWpL38sxRwjahk45aQxoMOk2FJm7iHnP6zAGUnqAiL8iCdTjn5sp/txNf22bXrx3YS54ePBrfZQxOvkOvE24XZKXXwIDAQAB"
}
