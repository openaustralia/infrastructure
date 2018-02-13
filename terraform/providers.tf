provider "aws" {
  version = "~> 1.8"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.ec2_region}"
}

provider "dme" {
  version    = "~> 0.1"
  akey       = "${var.dnsmadeeasy_akey}"
  skey       = "${var.dnsmadeeasy_skey}"
  usesandbox = false
}

provider "cloudflare" {
  version = "~> 0.1"
  email   = "${var.cloudflare_email}"
  token   = "${var.cloudflare_token}"
}
