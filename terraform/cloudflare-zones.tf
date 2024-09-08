
resource "cloudflare_zone" "oaf_org_au" {
  account_id = var.cloudflare_account_id
  plan       = "free"
  zone       = "oaf.org.au"
}

resource "cloudflare_zone" "openaustraliafoundation_org_au" {
  account_id = var.cloudflare_account_id
  plan       = "free"
  zone       = "openaustraliafoundation.org.au"
}

resource "cloudflare_zone" "righttoknow_org_au" {
  account_id = var.cloudflare_account_id
  plan       = "free"
  zone       = "righttoknow.org.au"
}

resource "cloudflare_zone" "theyvoteforyou_org_au" {
  account_id = var.cloudflare_account_id
  plan       = "free"
  zone       = "theyvoteforyou.org.au"
}

resource "cloudflare_zone" "theyvoteforyou_org" {
  account_id = var.cloudflare_account_id
  plan       = "free"
  zone       = "theyvoteforyou.org"
}

resource "cloudflare_zone" "theyvoteforyou_com_au" {
  account_id = var.cloudflare_account_id
  plan       = "free"
  zone       = "theyvoteforyou.com.au"
}
