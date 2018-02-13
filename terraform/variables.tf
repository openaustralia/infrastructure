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
variable "theyvoteforyou_dme_domainid" {
  default = "1828502"
}
# Default ttl to use for all records in this domain
variable "theyvoteforyou_dme_ttl" {
  default = 60
}
