resource "cloudflare_zone" "main" {
  account_id = var.cloudflare_account_id
  plan       = "free"
  zone       = "electionleaflets.org.au"
}

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

resource "cloudflare_record" "test" {
  zone_id = cloudflare_zone.main.id
  name    = "test.electionleaflets.org.au"
  type    = "CNAME"
  value   = "electionleaflets.org.au"
}

resource "cloudflare_record" "www_test" {
  zone_id = cloudflare_zone.main.id
  name    = "www.test.electionleaflets.org.au"
  type    = "CNAME"
  value   = "electionleaflets.org.au"
}

resource "cloudflare_record" "federal2010" {
  zone_id = cloudflare_zone.main.id
  name    = "federal2010.electionleaflets.org.au"
  type    = "CNAME"
  value   = "electionleaflets.org.au"
}

# TODO: Do we still need this?
resource "cloudflare_record" "google_domain_verification" {
  zone_id = cloudflare_zone.main.id
  name    = "googleffffffffc7db8b0c.electionleaflets.org.au"
  type    = "CNAME"
  value   = "google.com"
}

# MX records

# We can now use a single MX record for Google workspace
resource "cloudflare_record" "mx" {
  zone_id  = cloudflare_zone.main.id
  name     = "electionleaflets.org.au"
  type     = "MX"
  priority = 1
  value    = "smtp.google.com"
}

# TXT records
resource "cloudflare_record" "spf" {
  zone_id = cloudflare_zone.main.id
  name    = "electionleaflets.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:_spf.google.com ~all"
}

resource "cloudflare_record" "google_site_verification" {
  zone_id = cloudflare_zone.main.id
  name    = "electionleaflets.org.au"
  type    = "TXT"
  value   = "google-site-verification=3Nb8GKm812AwhbSI4GsOntVXeDFJT9nyk68RjQoRuYQ"
}

resource "cloudflare_record" "domainkey_google" {
  zone_id = cloudflare_zone.main.id
  name    = "google._domainkey.electionleaflets.org.au"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxi3IIb7fJ5Hn4R2W/zIbxA1T5YSQvsjFPIuR9YC5yJZkfsPKbd9IblkVr1PF6gNoHM4ADM7ArQuJTxQA/YIlrs63e6N+9iOIb8dXelzENTcpO+OFjRjBtuD3EMQxg9bfoHft+3WFfyMfsnXpQRAQO0J864w2YuVZs2wgvJFVkNo+HKeb8k099FA+lJg9zoRH0OjJDad6ITveb2/c+sXYS/83k1CI17C4F+6n3Y+aizELfeRZ2h38n8E3giGoiNyJmJzSFq/zYwWs11WG12gBmNshtJM7tn3kOyjWAUBT2REOTWkYm0IT957yqehr+YB5PquvLifx8Xsok4oie9y4SwIDAQAB"
}

# For the time being we're just using DMARC records to get some data on what's
# happening with email that we're sending (and whether anyone else is impersonating
# us).
# We're using a free service provided by https://dmarc.postmarkapp.com/
# This generates a weekly DMARC report which gets sent by email on Monday mornings
# Report goes to webmaster@electionleaflets.org.au
resource "cloudflare_record" "dmarc" {
  zone_id = cloudflare_zone.main.id
  name    = "_dmarc.electionleaflets.org.au"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+p2egbdcedhn@dmarc.postmarkapp.com; sp=none; aspf=r;"
}
