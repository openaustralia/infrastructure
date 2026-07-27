# DKIM record for mail sent via postal (docs/postal-migration.md). The
# selector name (postal-<tag>._domainkey.theyvoteforyou.org.au) and value are
# shown in the postal web interface once the domain is added there; set both
# in this module's call in terraform/main.tf.

variable "postal_dkim_record_name" {
  description = "Full record name of the postal DKIM TXT record, e.g. postal-abc123._domainkey.theyvoteforyou.org.au"
  default     = ""

  validation {
    condition = (
      (var.postal_dkim_record_name == "" && var.postal_dkim_record_value == "") ||
      (var.postal_dkim_record_name != "" && var.postal_dkim_record_value != "")
    )
    error_message = "postal_dkim_record_name and postal_dkim_record_value must either both be set or both be empty."
  }
}

variable "postal_dkim_record_value" {
  description = "Value of the postal DKIM TXT record (k=rsa; p=...)"
  default     = ""
}

resource "cloudflare_record" "postal_domainkey" {
  count   = var.postal_dkim_record_name != "" && var.postal_dkim_record_value != "" ? 1 : 0
  zone_id = cloudflare_zone.org_au.id
  name    = var.postal_dkim_record_name
  type    = "TXT"
  value   = var.postal_dkim_record_value
}
