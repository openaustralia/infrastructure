resource "cloudflare_record" "campaign_monitor_root" {
  zone_id = cloudflare_zone.oaf_org_au.id
  name    = "email.oaf.org.au"
  type    = "CNAME"
  value   = "cname.createsend.com"
}

resource "cloudflare_record" "campaign_monitor_domainkey" {
  zone_id = cloudflare_zone.oaf_org_au.id
  name    = "cm._domainkey.oaf.org.au"
  type    = "TXT"
  value   = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC7c0O/Ihi0wMb89k9UvkFPqM00DWEcm5kgCkhSTHN5rKcMtlCrijBYqZQgBcig/M6Zl6o6z9nKp4egpJ9Yf8ndZEz/r7AcQIeTjLwxIIlFSbABuBoQPoxTUrIvzRCWUTgCocvi3sNrzxYvYfFPq7LmxjI+RzK3UD84rKBaJtYULwIDAQAB"
}
