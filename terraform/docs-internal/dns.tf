## Contains the DNS records for handbook.oaf.org.au, our new internal documentation site. This is a separate module from the main terraform module because it is not hosted on AWS, but rather on mintlify.

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4.0"
    }
  }
}

# CNAME Record
resource "cloudflare_record" "docs" {
  zone_id = var.zone_id
  name    = "handbook.oaf.org.au"
  type    = "CNAME"
  value   = "cname.mintlify.builders"
}

# TXT Records
resource "cloudflare_record" "acme_challenge" {
  zone_id = var.zone_id
  name    = "_acme-challenge.handbook.oaf.org.au"
  type    = "TXT"
    value   = "_acme-challenge.handbook.oaf.org.au"
  }

  resource "cloudflare_record" "custom_hostname" {
    zone_id = var.zone_id
    name    = "_cf-custom-hostname.handbook.oaf.org.au"
    type    = "TXT"
    value   = "7d3c04c3-2a65-4d09-99dd-ac61add178f8"
  }
