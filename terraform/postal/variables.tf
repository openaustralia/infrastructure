variable "zone_id" {
  description = "Cloudflare zone id for oaf.org.au"
}

variable "authorized_key" {
  description = "SSH public key installed for root on first boot"
}

variable "return_path_dkim_record" {
  description = "Output of `postal default-dkim-record` (the k=rsa; p=... value). Leave empty until the server's signing key exists."
  default     = ""
}
