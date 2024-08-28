variable "ami" {}
variable "deployer_key" {}
variable "security_group" {}
variable "instance_profile" {}

variable "theyvoteforyou_org_au_zone_id" {
  default = "5ffc72ab294d0bdcd481fd19b9ab8326"
}

variable "theyvoteforyou_org_zone_id" {
  default = "4ea2ceb027e2299e27c8cc1a8c59b029"
}

variable "theyvoteforyou_com_au_zone_id" {
  default = "dd36844e39e23c27ae5f316bc516d692"
}
