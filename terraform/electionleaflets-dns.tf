# A records
resource "cloudflare_record" "el_root" {
  domain = "electionleaflets.org.au"
  name   = "electionleaflets.org.au"
  type   = "A"
  value  = "${aws_eip.kedumba.public_ip}"
}

# CNAME records
resource "cloudflare_record" "el_www" {
  domain = "electionleaflets.org.au"
  name   = "www.electionleaflets.org.au"
  type   = "CNAME"
  value  = "electionleaflets.org.au"
}

resource "cloudflare_record" "el_test" {
  domain = "electionleaflets.org.au"
  name   = "test.electionleaflets.org.au"
  type   = "CNAME"
  value  = "electionleaflets.org.au"
}

resource "cloudflare_record" "el_federal2010" {
  domain = "electionleaflets.org.au"
  name   = "federal2010.electionleaflets.org.au"
  type   = "CNAME"
  value  = "electionleaflets.org.au"
}

# TODO: Do we still need this?
resource "cloudflare_record" "el_google_domain_verification" {
  domain = "electionleaflets.org.au"
  name   = "googleffffffffc7db8b0c.electionleaflets.org.au"
  type   = "CNAME"
  value  = "google.com"
}

# MX records
resource "cloudflare_record" "el_mx1" {
  domain   = "electionleaflets.org.au"
  name     = "electionleaflets.org.au"
  type     = "MX"
  priority = 10
  value    = "aspmx.l.google.com"
}

resource "cloudflare_record" "el_mx2" {
  domain   = "electionleaflets.org.au"
  name     = "electionleaflets.org.au"
  type     = "MX"
  priority = 20
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "el_mx3" {
  domain   = "electionleaflets.org.au"
  name     = "electionleaflets.org.au"
  type     = "MX"
  priority = 20
  value    = "alt2.aspmx.l.google.com"
}

resource "cloudflare_record" "el_mx4" {
  domain   = "electionleaflets.org.au"
  name     = "electionleaflets.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx2.googlemail.com"
}

resource "cloudflare_record" "el_mx5" {
  domain   = "electionleaflets.org.au"
  name     = "electionleaflets.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx3.googlemail.com"
}

resource "cloudflare_record" "el_mx6" {
  domain   = "electionleaflets.org.au"
  name     = "electionleaflets.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx4.googlemail.com"
}

resource "cloudflare_record" "el_mx7" {
  domain   = "electionleaflets.org.au"
  name     = "electionleaflets.org.au"
  type     = "MX"
  priority = 30
  value    = "aspmx5.googlemail.com"
}

# TXT records
resource "cloudflare_record" "el_spf" {
  domain = "electionleaflets.org.au"
  name   = "electionleaflets.org.au"
  type   = "TXT"
  value  = "v=spf1 a include:_spf.google.com ~all"
}
