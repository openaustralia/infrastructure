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

variable "linode_api_token" {
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

# AMI for Ubuntu 16.04 LTS, locked to a specific version so that we don't
# keep re-provisioning the servers when the AMI gets updated
variable "ubuntu_16_ami" {
  # Name: ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180205
  # Created by: Canonical
  # Virtualization type: hvm
  default = "ami-e1c43f83"
}

# AMI for Ubuntu 18.04 LTS, locked to a specific version so that we don't
# keep re-provisioning the servers when the AMI gets updated
variable "ubuntu_18_ami" {
  # Name: ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20220131
  # Created by: Canonical
  # Virtualization type: hvm
  default = "ami-0510efc4f138a88e1"
}

# AMI for Ubuntu 20.04 LTS, locked to a specific version so that we don't
# keep re-provisioning the servers when the AMI gets updated
variable "ubuntu_20_ami" {
  # Created by: Canonical
  # Virtualization type: hvm
  default = "ami-0b7dcd6e6fd797935"
}

# AMI for Ubuntu 22.04 LTS, locked to a specific version so that we don't
# keep re-provisioning the servers when the AMI gets updated
variable "ubuntu_22_ami" {
  # Created by: Canonical
  # Virtualization type: hvm
  default = "ami-0df609f69029c9bdb"
}

resource "cloudflare_zone" "oaf_org_au" {
  account_id = "668e6ebb9952c26ec3c17a85fb3a25a1"
  zone       = "oaf.org.au"
  plan       = "free"
}

variable "electionleaflets_org_au_zone_id" {
  default = "4cd5afd47047e6a7e37563d013d431ae"
}

variable "morph_io_zone_id" {
  default = "194b659721d5dafa766f2064a5ac8819"
}

variable "openaustraliafoundation_org_au_zone_id" {
  default = "5774055545c9ecb0d16b723857185e0e"
}

variable "openaustralia_org_zone_id" {
  default = "6f375d3f3dcd53599e538454c02161b2"
}

variable "openaustralia_org_au_zone_id" {
  default = "f8ae8cc5a255e25cc39bbb91177dfc47"
}

variable "opengovernment_org_au_zone_id" {
  default = "980de1807f4ff1c23c4b7dcfed7b31df"
}

variable "planningalerts_zone_id" {
  default = "a826a2cd0f87d57ef60dc67c5738eec5"
}

variable "righttoknow_org_au_zone_id" {
  default = "44b07a3486191276e3e6b0919dd86fff"
}

variable "theyvoteforyou_org_au_zone_id" {
  default = "5ffc72ab294d0bdcd481fd19b9ab8326"
}

variable "theyvoteforyou_org_zone_id" {
  default = "4ea2ceb027e2299e27c8cc1a8c59b029"
}

variable "theyvoteforyou_com_au_zone_id" {
  default = "dd36844e39e23c27ae5f316bc516d692"
}
