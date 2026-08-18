variable "zone_id" {}

variable "authorized_keys" {
  description = "SSH public keys installed on the root account of the instance"
  type        = list(string)
}
