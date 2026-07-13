# DKIM record for mail the oaf.org.au wordpress site sends via postal
# (docs/postal-migration.md), replacing the badly-named civicrm_37 cuttlefish
# record eventually. The selector name (postal-<tag>._domainkey.oaf.org.au)
# and value are shown in the postal web interface once the domain is added
# there; set both in this module's call in terraform/main.tf.

variable "postal_dkim_record_name" {
  description = "Full record name of the postal DKIM TXT record, e.g. postal-abc123._domainkey.oaf.org.au"
  default     = ""
}

variable "postal_dkim_record_value" {
  description = "Value of the postal DKIM TXT record (k=rsa; p=...)"
  default     = ""
}

resource "cloudflare_record" "postal_domainkey" {
  count   = var.postal_dkim_record_name == "" ? 0 : 1
  zone_id = var.oaf_org_au_zone_id
  name    = var.postal_dkim_record_name
  type    = "TXT"
  value   = var.postal_dkim_record_value
}
