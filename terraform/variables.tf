# Note that currently there is duplication between these values and those stored
# and used in ansible
# TODO: Remove duplication

variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "ec2_region" {
  # Sydney
  default = "ap-southeast-2"
}

variable "rds_admin_password" {
}

variable "theyvoteforyou_db_password" {
}

# Note that this is different than one that was previously called cloudflare_token
variable "cloudflare_api_token" {
}

# TODO: Get this automatically by managing Linode infrastructure with terraform
variable "cuttlefish_ipv4" {
  default = "23.239.22.35"
}

# TODO: Get this automatically by managing Linode infrastructure with terraform
variable "cuttlefish_ipv6" {
  default = "2600:3c01::f03c:91ff:fe89:1913"
}

# TODO: Get this automatically by managing Linode infrastructure with terraform
variable "morph_ipv4" {
  default = "173.255.208.251"
}

# AMI for Ubuntu 16.04, locked to a specific version so that we don't
# keep re-provisioning the servers when the AMI gets updated
variable "ubuntu_16_ami" {
  # Name: ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180205
  # Created by: Canonical
  # Virtualization type: hvm
  default = "ami-e1c43f83"
}
