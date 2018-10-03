# A records
resource "cloudflare_record" "pa_root" {
  domain = "planningalerts.org.au"
  name   = "planningalerts.org.au"
  type   = "A"
  value  = "${aws_eip.planningalerts.public_ip}"
}

# CNAME records

resource "cloudflare_record" "pa_www" {
  domain = "planningalerts.org.au"
  name   = "www.planningalerts.org.au"
  type   = "CNAME"
  value  = "planningalerts.org.au"
}

resource "cloudflare_record" "pa_api" {
  domain = "planningalerts.org.au"
  name   = "api.planningalerts.org.au"
  type   = "CNAME"
  value  = "planningalerts.org.au"
}

resource "cloudflare_record" "pa_test" {
  domain = "planningalerts.org.au"
  name   = "test.planningalerts.org.au"
  type   = "CNAME"
  value  = "planningalerts.org.au"
}

resource "cloudflare_record" "pa_www_test" {
  domain = "planningalerts.org.au"
  name   = "www.test.planningalerts.org.au"
  type   = "CNAME"
  value  = "planningalerts.org.au"
}

resource "cloudflare_record" "pa_api_test" {
  domain = "planningalerts.org.au"
  name   = "api.test.planningalerts.org.au"
  type   = "CNAME"
  value  = "planningalerts.org.au"
}

resource "cloudflare_record" "pa_email" {
  domain = "planningalerts.org.au"
  name   = "email.planningalerts.org.au"
  type   = "CNAME"
  value  = "cuttlefish.io"
}

resource "cloudflare_record" "pa_email2" {
  domain = "planningalerts.org.au"
  name   = "email2.planningalerts.org.au"
  type   = "CNAME"
  value  = "cuttlefish.oaf.org.au"
}

# MX records
resource "cloudflare_record" "pa_mx1" {
  domain   = "planningalerts.org.au"
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 1
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "pa_mx2" {
  domain   = "planningalerts.org.au"
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 5
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "pa_mx3" {
  domain   = "planningalerts.org.au"
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 5
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "pa_mx4" {
  domain   = "planningalerts.org.au"
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "pa_mx5" {
  domain   = "planningalerts.org.au"
  name     = "planningalerts.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx3.googlemail.com"
}

# TXT records

resource "cloudflare_record" "pa_spf" {
  domain = "planningalerts.org.au"
  name   = "planningalerts.org.au"
  type   = "TXT"
  value  = "v=spf1 include:_spf.google.com a:cuttlefish.oaf.org.au  -all"
}

resource "cloudflare_record" "pa_google_site_verification" {
  domain = "planningalerts.org.au"
  name   = "planningalerts.org.au"
  type   = "TXT"
  value  = "google-site-verification=wZp42fwpmr6aGdCVqp7BJBn_kenD51hYLig7cMOFIBs"
}

resource "cloudflare_record" "pa_domainkey" {
  domain = "planningalerts.org.au"
  name   = "cuttlefish._domainkey.planningalerts.org.au"
  type   = "TXT"
  value  = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoUPCB2huZQkwFnEMn0/jorQ/nHsNul1gQqHbQsX2unANX+dXnnmF0y+rFnB93mlmOVemv+vnQik/DGr+3aCQqOia5t5xXTsbPenmstC1tfCNDl9irQb7sCP8IeiLdcxJ5upsH8PtAod9r7J/Uo8KdXxMPbBFvVT/X9qe25dHkZUqwJHGn7peLmSTe2Ti4ZRTlyolc1orKD7sHx7iI+lU/9Ga1at2kykrXGAs4bUDPY2cmsSMcwqYRu6DQgBz01g9pqaOmDZ7mKwbI7M2m9kX6AWFCb9YqyeyZpW42bytlsKiVsH5bwQmhNFJ/vqTuwyyvBlIDcforixhRGZ13Ufj2QIDAQAB"
}


#Front DNS records
resource "cloudflare_record" "oaf_pa_front_mx" {
  domain = "planningalerts.org.au"
  name = "front-mail.planningalerts.org.au"
  type = "MX"
  priority = 100
  value = "mx.sendgrid.net"
}

resource "cloudflare_record" "oaf_pa_front_spf" {
  domain = "planningalerts.org.au"
  name   = "front-mail.planningalerts.org.au"
  type   = "TXT"
  value  = "v=spf1 a include:sendgrid.net ~all"
}

resource "cloudflare_record" "oaf_pa_front_domainkey" {
  domain = "planningalerts.org.au"
  name   = "m1._domainkey.planningalerts.org.au"
  type   = "TXT"
  value  = "k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4PZZJiwMfMB/CuIZ9yAtNEGzfKzQ7WC7hfGg8UyavtYlDDBgSP6P1AiTBTMzTQbLChvf+Ef5CK46w+RwmgWpL38sxRwjahk45aQxoMOk2FJm7iHnP6zAGUnqAiL8iCdTjn5sp/txNf22bXrx3YS54ePBrfZQxOvkOvE24XZKXXwIDAQAB"
}
