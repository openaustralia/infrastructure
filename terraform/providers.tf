provider "aws" {
  version    = "~> 2.40.0"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.ec2_region
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
  version = "~> 2.1.0"
  api_token = var.cloudflare_api_token
}

provider "external" {
  version = "~> 1.2"
}
