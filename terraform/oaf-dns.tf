# A records
resource "cloudflare_record" "oaf_root" {
  domain = "oaf.org.au"
  name   = "oaf.org.au"
  type   = "A"
  value  = "103.243.244.10"
}

resource "cloudflare_record" "oaf_cuttlefish" {
  domain = "oaf.org.au"
  name   = "cuttlefish.oaf.org.au"
  type   = "A"
  value  = "23.239.22.35"
}

resource "cloudflare_record" "oaf_kedumba" {
  domain = "oaf.org.au"
  name   = "kedumba.oaf.org.au"
  type   = "A"
  value  = "103.243.244.10"
}

# AAAA records
resource "cloudflare_record" "oaf_aaaa_cuttlefish" {
  domain = "oaf.org.au"
  name   = "cuttlefish.oaf.org.au"
  type   = "AAAA"
  value  = "2600:3c01::f03c:91ff:fe89:1913"
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
  value  = "v=spf1 include:_spf.google.com ip4:23.239.22.35 ip6:2600:3c01::f03c:91ff:fe89:1913 -all"
}

resource "cloudflare_record" "oaf_cuttlefish_domainkey" {
  domain = "oaf.org.au"
  name   = "cuttlefish._domainkey.cuttlefish.oaf.org.au"
  type   = "TXT"
  value  = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvEPfY69ZLYEn+I8rXaRLpTTb9c8AAEdjlUIPAX5nZ2cPYRxA8eCO/AYgXGXXdvGYWUm7sDkil6oSlqZjLx3au31AOoPNimi8FT2QjSgDp/Qkd403ACW314Aio4lo39y+un4GK0ih6KDuJAcxSftoGd9DFViBkVUs8Cs/WhFnc2dkhKTpCtt8Mji+bNtTOYsFwAg8LC3tDnWg+V3UTqqFQBi476DemGPVjxtpe48uFjCQpGg8T0uW54cIKWiC3PWCU0Ksj3HVMhE8P33McW/VFyGAx+nDlc0i6VY3zZi2i86O9Z84j0bJm/607lFK/pCa/Rv8hSJz5Ksk2EkD0NKh0QIDAQAB"
}
