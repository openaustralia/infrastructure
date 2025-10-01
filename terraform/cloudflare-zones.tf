
resource "cloudflare_zone" "oaf_org_au" {
  account_id = var.cloudflare_account_id
  plan       = "business"
  zone       = "oaf.org.au"
}

resource "cloudflare_zone" "openaustraliafoundation_org_au" {
  account_id = var.cloudflare_account_id
  plan       = "free"
  zone       = "openaustraliafoundation.org.au"
}
