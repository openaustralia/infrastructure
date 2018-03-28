provider "aws" {
  version = "~> 1.8"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.ec2_region}"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "ap-southeast-1"
  region = "ap-southeast-1"
}

provider "cloudflare" {
  version = "~> 0.1"
  email   = "${var.cloudflare_email}"
  token   = "${var.cloudflare_token}"
}
