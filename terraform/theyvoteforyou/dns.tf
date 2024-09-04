## theyvoteforyou.org.au

# A records
resource "cloudflare_record" "root" {
  zone_id = var.org_au_zone_id
  name    = "theyvoteforyou.org.au"
  type    = "A"
  value   = aws_eip.main.public_ip
}

# CNAME records

resource "cloudflare_record" "www" {
  zone_id = var.org_au_zone_id
  name    = "www.theyvoteforyou.org.au"
  type    = "CNAME"
  value   = "theyvoteforyou.org.au"
}

resource "cloudflare_record" "test" {
  zone_id = var.org_au_zone_id
  name    = "test.theyvoteforyou.org.au"
  type    = "CNAME"
  value   = "theyvoteforyou.org.au"
}

resource "cloudflare_record" "www_test" {
  zone_id = var.org_au_zone_id
  name    = "www.test.theyvoteforyou.org.au"
  type    = "CNAME"
  value   = "theyvoteforyou.org.au"
}

resource "cloudflare_record" "email" {
  zone_id = var.org_au_zone_id
  name    = "email.theyvoteforyou.org.au"
  type    = "CNAME"
  value   = "cuttlefish.io"
}

resource "cloudflare_record" "email2" {
  zone_id = var.org_au_zone_id
  name    = "email2.theyvoteforyou.org.au"
  type    = "CNAME"
  value   = "cuttlefish.oaf.org.au"
}

# MX records

# We can now use a single MX record for Google workspace
resource "cloudflare_record" "mx" {
  zone_id  = var.org_au_zone_id
  name     = "theyvoteforyou.org.au"
  type     = "MX"
  priority = 1
  value    = "smtp.google.com"
}

# TXT records

# TODO: I think this spf record needs to include cuttlefish (like planningalerts)
resource "cloudflare_record" "spf" {
  zone_id = var.org_au_zone_id
  name    = "theyvoteforyou.org.au"
  type    = "TXT"
  value   = "v=spf1 include:_spf.google.com -all"
}

# TODO: Remove this once the one below is up and running
resource "cloudflare_record" "cuttlefish" {
  zone_id = var.org_au_zone_id
  name    = "cuttlefish._domainkey.theyvoteforyou.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0toFOrXAOcbnS8LNeKQsetYEO4Qh1RLGCx9+prCDeXBgs0obFCPWyanqxiPL6WEZCv+Vj4TCBPfoVCR1G0hszOZIA1QCEx0tG4v3dE2QsS3tSVCl9ax1h0oi4fC5aJ7XdxI+e2JVcWwmSSCLoKbkJYpj+6VBr86jUZl6f3JeUH/RuIeS6jIHRFmM6Mz/BfzloxM2wbDK320DUs3yWkL3/RcwkT6ebI9oS+ZWIxKXAgEcreTG0JltgPR/ABPFNzms4mAtLwPojF/FAYzGCj6diGbB61LNcMwe0MrutvLucclhnSefG5E3GVNqLrQA1oXzwFLFsq1H0x8rFccm+GNAuQIDAQAB"
}

resource "cloudflare_record" "cuttlefish2" {
  zone_id = var.org_au_zone_id
  name    = "they_vote_for_you_4.cuttlefish._domainkey.theyvoteforyou.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0toFOrXAOcbnS8LNeKQsetYEO4Qh1RLGCx9+prCDeXBgs0obFCPWyanqxiPL6WEZCv+Vj4TCBPfoVCR1G0hszOZIA1QCEx0tG4v3dE2QsS3tSVCl9ax1h0oi4fC5aJ7XdxI+e2JVcWwmSSCLoKbkJYpj+6VBr86jUZl6f3JeUH/RuIeS6jIHRFmM6Mz/BfzloxM2wbDK320DUs3yWkL3/RcwkT6ebI9oS+ZWIxKXAgEcreTG0JltgPR/ABPFNzms4mAtLwPojF/FAYzGCj6diGbB61LNcMwe0MrutvLucclhnSefG5E3GVNqLrQA1oXzwFLFsq1H0x8rFccm+GNAuQIDAQAB"
}

resource "cloudflare_record" "google_site_verification" {
  zone_id = var.org_au_zone_id
  name    = "theyvoteforyou.org.au"
  type    = "TXT"
  value   = "google-site-verification=DHISCv3WoPmTzUWzYfzpeBd5NivPxC5a2s4uBdWZoY8"
}

resource "cloudflare_record" "facebook_domain_verification" {
  zone_id = var.org_au_zone_id
  name    = "theyvoteforyou.org.au"
  type    = "TXT"
  value   = "facebook-domain-verification=gl65oi4ss3xepcuasglgxgqlhj1lbg"
}

resource "cloudflare_record" "tvfy_domainkey_google" {
  zone_id = var.org_au_zone_id
  name    = "google._domainkey.theyvoteforyou.org.au"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6GEPSzIyB0M2Fpuk6nAJth9sE3xU30e7dn5Q1NihGNbBaxFP01qxohr6eP0F2OeokQI0Gk7/uxtl0mWNe7oCdgxjflX7DVW5B5jSpXUI3wM5sppFFvwen3joDhnWP4fnu8PLkBNTcJ32crG2u4BcyCBaz7bmM7utFZgnsTo1NuAaq6Hs5SU2nv4i5dPgbSF9UjjZ+/FfCXqzmQpmWHVGvyweHiVosXX/nZyYl9QeroT2YDpcD93DIidtiDR79QPDqLtqAk8lJFN9nyYo9DCnsxheROXHfPFlr1tkhYJJ+HxSnB368SZFH3HNzhvS9WYscjYYXHw1TtI972MOCtPqiwIDAQAB"
}

# For the time being we're just using DMARC records to get some data on what's
# happening with email that we're sending (and whether anyone else is impersonating
# us).
# We're using a free service provided by https://dmarc.postmarkapp.com/
# This generates a weekly DMARC report which gets sent by email on Monday mornings
# Report goes to webmaster@theyvoteforyou.org.au
resource "cloudflare_record" "tvfy_dmarc" {
  zone_id = var.org_au_zone_id
  name    = "_dmarc.theyvoteforyou.org.au"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+ldnqce6nisu@dmarc.postmarkapp.com; sp=none; aspf=r;"
}

## theyvoteforyou.org

resource "cloudflare_record" "alt1_root" {
  zone_id = var.org_zone_id
  name    = "theyvoteforyou.org"
  type    = "A"
  value   = aws_eip.main.public_ip
}

resource "cloudflare_record" "alt1_www" {
  zone_id = var.org_zone_id
  name    = "www.theyvoteforyou.org"
  type    = "CNAME"
  value   = "theyvoteforyou.org"
}

# For the time being we're just using DMARC records to get some data on what's
# happening with email that we're sending (and whether anyone else is impersonating
# us).
# We're using a free service provided by https://dmarc.postmarkapp.com/
# This generates a weekly DMARC report which gets sent by email on Monday mornings
# Report goes to webmaster@theyvoteforyou.org
resource "cloudflare_record" "tvfy_alt1_dmarc" {
  zone_id = var.org_zone_id
  name    = "_dmarc.theyvoteforyou.org"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+qbce7gaoklg@dmarc.postmarkapp.com; sp=none; aspf=r;"
}

## theyvoteforyou.com.au

resource "cloudflare_record" "alt2_root" {
  zone_id = var.com_au_zone_id
  name    = "theyvoteforyou.com.au"
  type    = "A"
  value   = aws_eip.main.public_ip
}

resource "cloudflare_record" "alt2_www" {
  zone_id = var.com_au_zone_id
  name    = "www.theyvoteforyou.com.au"
  type    = "CNAME"
  value   = "theyvoteforyou.com.au"
}

# For the time being we're just using DMARC records to get some data on what's
# happening with email that we're sending (and whether anyone else is impersonating
# us).
# We're using a free service provided by https://dmarc.postmarkapp.com/
# This generates a weekly DMARC report which gets sent by email on Monday mornings
# Report goes to webmaster@theyvoteforyou.com.au
resource "cloudflare_record" "tvfy_alt2_dmarc" {
  zone_id = var.com_au_zone_id
  name    = "_dmarc.theyvoteforyou.com.au"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+ffljniarmuh@dmarc.postmarkapp.com; sp=none; aspf=r;"
}
