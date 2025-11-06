resource "cloudflare_zone" "main" {
  account_id = var.cloudflare_account_id
  plan       = "business"
  zone       = "righttoknow.org.au"
}

# A records
resource "cloudflare_record" "root" {
  zone_id = cloudflare_zone.main.id
  name    = "righttoknow.org.au"
  type    = "A"
  value   = aws_eip.production.public_ip
}

resource "cloudflare_record" "production" {
  zone_id = cloudflare_zone.main.id
  name    = "prod.righttoknow.org.au"
  type    = "A"
  value   = aws_eip.production.public_ip
  
}


# CNAME records
resource "cloudflare_record" "www" {
  zone_id = cloudflare_zone.main.id
  name    = "www.righttoknow.org.au"
  type    = "CNAME"
  value   = "righttoknow.org.au"
}

resource "cloudflare_record" "test" {
  zone_id = cloudflare_zone.main.id
  name    = "test.righttoknow.org.au"
  type    = "CNAME"
  value   = "righttoknow.org.au"
}

resource "cloudflare_record" "www_test" {
  zone_id = cloudflare_zone.main.id
  name    = "www.test.righttoknow.org.au"
  type    = "CNAME"
  value   = "righttoknow.org.au"
}

# MX records

# We can now use a single MX record for Google workspace
resource "cloudflare_record" "mx" {
  zone_id  = cloudflare_zone.main.id
  name     = "righttoknow.org.au"
  type     = "MX"
  priority = 1
  value    = "smtp.google.com"
}

# TODO Check how this record is being used
resource "cloudflare_record" "server" {
  zone_id  = cloudflare_zone.main.id
  name     = "server.righttoknow.org.au"
  type     = "MX"
  priority = 10
  value    = "righttoknow.org.au"
}

# TXT records
resource "cloudflare_record" "spf" {
  zone_id = cloudflare_zone.main.id
  name    = "righttoknow.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:_spf.google.com ~all"
}

resource "cloudflare_record" "google_site_verification" {
  zone_id = cloudflare_zone.main.id
  name    = "righttoknow.org.au"
  type    = "TXT"
  value   = "google-site-verification=ci77kXOm4-lxR3Tc1D1FlTzz0J_GWQES2wU5kFMIR-w"
}

resource "cloudflare_record" "facebook_domain_verification" {
  zone_id = cloudflare_zone.main.id
  name    = "righttoknow.org.au"
  type    = "TXT"
  value   = "facebook-domain-verification=vtlcbmfm4mihp4wql58lwz3nbhc8bt"
}

# Note that this record comes from roles/internal/righttoknow/files/dkimkeys/default.txt which in turn is generated
# by hand (as part of a keypair) using opendkim
resource "cloudflare_record" "default_domainkey" {
  zone_id = cloudflare_zone.main.id
  name    = "default._domainkey.righttoknow.org.au"
  type    = "TXT"
  value   = "v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzWFLO143fpHeVU27EjmOsY4hpKtR+/PI+idJItMWiHSwjgcX21QYMbQjPcHfHFhsDbblBBQy/MtcTwynSYFp1SWkTI8EsHLS1+pp1HAI3wx7ZWLmwE6di+qRKu+3ooPFSIUbA+TvA7GJmHBfBf/ubASWff4t5ByZ9edZOA4lZ7pGdG7O0duH+/hhggH/LFMPX6a0CzyXYjsfTvtyYMJvvRsoepEs/QjtdBarZS2roR7qxZQhSRUlbZgSNAbyO0+3wJptpxvAXleSuOFoN5nHMV4LT+vuF0g+FDxIpbJu+bW08IKL1qMSH8Gtwd20Hy34h88IHPg8zx5FUoeeOS5W/wIDAQAB"
}

resource "cloudflare_record" "google_domainkey" {
  zone_id = cloudflare_zone.main.id
  name    = "google._domainkey.righttoknow.org.au"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAm30i+FaCipo1Eef8vrV66CRcdQGDfniuKP1ND2hj0VKiYf9LO15q7ZF9mE14zlOKmP//tS/EbdEXk6eAi0ps6oUf2jIvajyuDzLhz7Xn528LQDdxDRlh+2IdA+Z7jslLW7y0zJdYyp12X/Nx+mZrwbgoZJHplcmIZHQYWv00HX46ioR9eK8Yf6+0kU31ScAMcAphmjS4euYejsY0I0SoTlYDqJ/XNiiE2bl8wFfoG6/mgdHddpuPKKEs0cJc0Opt6ZzHuLdzQ+atnZJkqKQZWhkvrsMqeODBOoCE44SCW+5smT6TARDnGrnKTzvfEPZGoLQPojQHc3Ii+Bq3FtFsFwIDAQAB"
}

## 2024-09-02 - Set DMARC to quarantine emails that don't meet the DMARC requirements.
# We're using a free service provided by https://dmarc.postmarkapp.com/
# This generates a weekly DMARC report which gets sent by email on Monday mornings
# Report goes to webmaster@righttoknow.org.au
resource "cloudflare_record" "dmarc" {
  zone_id = cloudflare_zone.main.id
  name    = "_dmarc.righttoknow.org.au"
  type    = "TXT"
  value   = "v=DMARC1; p=quarantine; rua=mailto:re+aysyay6u9ct@dmarc.postmarkapp.com; sp=none; pct=100; aspf=r;"
}

# Staging environment DNS records
resource "cloudflare_record" "staging" {
  zone_id = cloudflare_zone.main.id
  name    = "staging.righttoknow.org.au"
  type    = "A"
  value   = aws_eip.staging.public_ip
}

resource "cloudflare_record" "www_staging" {
  zone_id = cloudflare_zone.main.id
  name    = "www.staging.righttoknow.org.au"
  type    = "CNAME"
  value   = "staging.righttoknow.org.au"
}

resource "cloudflare_record" "staging-spf" {
  zone_id = cloudflare_zone.main.id
  name    = "staging.righttoknow.org.au"
  type    = "TXT"
  value   = "v=spf1 a include:_spf.google.com ~all"
}

resource "cloudflare_record" "staging-mx" {
  zone_id  = cloudflare_zone.main.id
  name     = "staging.righttoknow.org.au"
  type     = "MX"
  priority = 1
  value    = "smtp.google.com"
}
