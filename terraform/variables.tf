# Note that currently there is duplication between these values and those stored
# and used in ansible
# TODO: Remove duplication

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "ec2_region" {
  # Sydney
  default = "ap-southeast-2"
}
variable "rds_admin_password" {}
variable "dnsmadeeasy_akey" {}
variable "dnsmadeeasy_skey" {}
variable "cloudflare_email" {
  default = "matthew@oaf.org.au"
}
variable "cloudflare_token" {}

# TODO: Get this automatically by managing Linode infrastructure with terraform
variable "cuttlefish_ipv4" {
  default = "23.239.22.35"
}
# TODO: Get this automatically by managing Linode infrastructure with terraform
variable "cuttlefish_ipv6" {
  default = "2600:3c01::f03c:91ff:fe89:1913"
}
