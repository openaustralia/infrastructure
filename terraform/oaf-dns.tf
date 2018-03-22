## oaf.org.au
# A records
resource "cloudflare_record" "oaf_root" {
  domain = "oaf.org.au"
  name   = "oaf.org.au"
  type   = "A"
  value  = "${aws_eip.oaf.public_ip}"
}

resource "cloudflare_record" "oaf_cuttlefish" {
  domain = "oaf.org.au"
  name   = "cuttlefish.oaf.org.au"
  type   = "A"
  value  = "${var.cuttlefish_ipv4}"
}

resource "cloudflare_record" "oaf_kedumba" {
  domain = "oaf.org.au"
  name   = "kedumba.oaf.org.au"
  type   = "A"
  value  = "${aws_eip.kedumba.public_ip}"
}

# AAAA records
resource "cloudflare_record" "oaf_aaaa_cuttlefish" {
  domain = "oaf.org.au"
  name   = "cuttlefish.oaf.org.au"
  type   = "AAAA"
  value  = "${var.cuttlefish_ipv6}"
}

# CNAME records
resource "cloudflare_record" "oaf_test" {
  domain = "oaf.org.au"
  name   = "test.oaf.org.au"
  type   = "CNAME"
  value  = "oaf.org.au"
}

resource "cloudflare_record" "oaf_www" {
  domain = "oaf.org.au"
  name   = "www.oaf.org.au"
  type   = "CNAME"
  value  = "oaf.org.au"
}

# MX records
resource "cloudflare_record" "oaf_mx1" {
  domain   = "oaf.org.au"
  name     = "oaf.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_mx2" {
  domain   = "oaf.org.au"
  name     = "oaf.org.au"
  type     = "MX"
  priority = 20
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_mx3" {
  domain   = "oaf.org.au"
  name     = "oaf.org.au"
  type     = "MX"
  priority = 20
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_mx4" {
  domain   = "oaf.org.au"
  name     = "oaf.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "oaf_mx5" {
  domain   = "oaf.org.au"
  name     = "oaf.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx3.googlemail.com"
}

resource "cloudflare_record" "oaf_cuttlefish_mx1" {
  domain   = "oaf.org.au"
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 1
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_cuttlefish_mx2" {
  domain   = "oaf.org.au"
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 5
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_cuttlefish_mx3" {
  domain   = "oaf.org.au"
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 5
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_cuttlefish_mx4" {
  domain   = "oaf.org.au"
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "oaf_cuttlefish_mx5" {
  domain   = "oaf.org.au"
  name     = "cuttlefish.oaf.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx3.googlemail.com"
}

# TXT records
resource "cloudflare_record" "oaf_spf" {
  domain = "oaf.org.au"
  name   = "oaf.org.au"
  type   = "TXT"
  value  = "v=spf1 a include:_spf.google.com ~all"
}

resource "cloudflare_record" "oaf_google_site_verification" {
  domain = "oaf.org.au"
  name   = "oaf.org.au"
  type   = "TXT"
  value  = "google-site-verification=RLhe_zgIDJMxpFFYFewv0KaRlWQvH-JDBxxpEV-8noY"
}

resource "cloudflare_record" "oaf_cuttlefish_spf" {
  domain = "oaf.org.au"
  name   = "cuttlefish.oaf.org.au"
  type   = "TXT"
  value  = "v=spf1 include:_spf.google.com ip4:${var.cuttlefish_ipv4} ip6:${var.cuttlefish_ipv6} -all"
}

resource "cloudflare_record" "oaf_cuttlefish_domainkey" {
  domain = "oaf.org.au"
  name   = "cuttlefish._domainkey.cuttlefish.oaf.org.au"
  type   = "TXT"
  value  = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvEPfY69ZLYEn+I8rXaRLpTTb9c8AAEdjlUIPAX5nZ2cPYRxA8eCO/AYgXGXXdvGYWUm7sDkil6oSlqZjLx3au31AOoPNimi8FT2QjSgDp/Qkd403ACW314Aio4lo39y+un4GK0ih6KDuJAcxSftoGd9DFViBkVUs8Cs/WhFnc2dkhKTpCtt8Mji+bNtTOYsFwAg8LC3tDnWg+V3UTqqFQBi476DemGPVjxtpe48uFjCQpGg8T0uW54cIKWiC3PWCU0Ksj3HVMhE8P33McW/VFyGAx+nDlc0i6VY3zZi2i86O9Z84j0bJm/607lFK/pCa/Rv8hSJz5Ksk2EkD0NKh0QIDAQAB"
}

## openaustraliafoundation.org.au

# A records

resource "cloudflare_record" "oaf_alt_root" {
  domain = "openaustraliafoundation.org.au"
  name   = "openaustraliafoundation.org.au"
  type   = "A"
  value  = "${aws_eip.oaf.public_ip}"
}

resource "cloudflare_record" "oaf_alt_kedumba" {
  domain = "openaustraliafoundation.org.au"
  name   = "kedumba.openaustraliafoundation.org.au"
  type   = "A"
  value  = "${aws_eip.kedumba.public_ip}"
}

# CNAME records
resource "cloudflare_record" "oaf_alt_www" {
  domain = "openaustraliafoundation.org.au"
  name   = "www.openaustraliafoundation.org.au"
  type   = "CNAME"
  value  = "openaustraliafoundation.org.au"
}

resource "cloudflare_record" "oaf_alt_test" {
  domain = "openaustraliafoundation.org.au"
  name   = "test.openaustraliafoundation.org.au"
  type   = "CNAME"
  value  = "openaustraliafoundation.org.au"
}

# MX records
resource "cloudflare_record" "oaf_alt_mx1" {
  domain   = "openaustraliafoundation.org.au"
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_alt_mx2" {
  domain   = "openaustraliafoundation.org.au"
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 20
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_alt_mx3" {
  domain   = "openaustraliafoundation.org.au"
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 20
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "oaf_alt_mx4" {
  domain   = "openaustraliafoundation.org.au"
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "oaf_alt_mx5" {
  domain   = "openaustraliafoundation.org.au"
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx3.googlemail.com"
}

resource "cloudflare_record" "oaf_alt_mx6" {
  domain   = "openaustraliafoundation.org.au"
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx4.googlemail.com"
}

resource "cloudflare_record" "oaf_alt_mx7" {
  domain   = "openaustraliafoundation.org.au"
  name     = "openaustraliafoundation.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx5.googlemail.com"
}

resource "cloudflare_record" "oaf_alt_kedumba_mx" {
  domain   = "openaustraliafoundation.org.au"
  name     = "kedumba.openaustraliafoundation.org.au"
  type     = "MX"
  priority = 10
  value    = "kedumba.openaustraliafoundation.org.au"
}

# TXT records
resource "cloudflare_record" "oaf_alt_spf" {
  domain = "openaustraliafoundation.org.au"
  name   = "openaustraliafoundation.org.au"
  type   = "TXT"
  value  = "v=spf1 a include:_spf.google.com ~all"
}
