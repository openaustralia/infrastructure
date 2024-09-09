terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4.0"
    }
  }
}
resource "cloudflare_record" "root" {
  zone_id = var.zone_id
  name    = "email.oaf.org.au"
  type    = "CNAME"
  value   = "cname.createsend.com"
}

moved {
  from = cloudflare_record.campaign_monitor_root
  to   = cloudflare_record.root
}

resource "cloudflare_record" "domainkey" {
  zone_id = var.zone_id
  name    = "cm._domainkey.oaf.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC7c0O/Ihi0wMb89k9UvkFPqM00DWEcm5kgCkhSTHN5rKcMtlCrijBYqZQgBcig/M6Zl6o6z9nKp4egpJ9Yf8ndZEz/r7AcQIeTjLwxIIlFSbABuBoQPoxTUrIvzRCWUTgCocvi3sNrzxYvYfFPq7LmxjI+RzK3UD84rKBaJtYULwIDAQAB"
}

moved {
  from = cloudflare_record.campaign_monitor_domainkey
  to   = cloudflare_record.domainkey
}
