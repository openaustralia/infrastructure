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
