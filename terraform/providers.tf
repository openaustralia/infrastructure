# Provider credentials:
#   AWS         — `~/.aws/credentials`, AWS_PROFILE, AWS SSO, instance profile, or AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY env vars
#   Google      — `gcloud auth application-default login`
#   Cloudflare  — var.cloudflare_api_token, rendered into secrets.auto.tfvars from 1Password by `make tf-secrets`
#   Linode      — var.linode_api_token, rendered into secrets.auto.tfvars from 1Password by `make tf-secrets`

provider "aws" {
  region = var.ec2_region
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
  api_token = var.cloudflare_api_token
}

provider "google" {
  project               = "planningalerts-214303"
  region                = "australia-southeast1"
  zone                  = "australia-southeast1-a"
  user_project_override = true
  billing_project       = "planningalerts-214303"
}

provider "linode" {
  token = var.linode_api_token
}
