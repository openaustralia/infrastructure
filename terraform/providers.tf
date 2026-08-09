# Provider credentials:
#   AWS         — the `oaf-legacy` profile (see README "CLI tools for credentials")
#   Google      — `gcloud auth application-default login`
#   Cloudflare  — var.cloudflare_api_token, rendered into secrets.auto.tfvars from 1Password by `make tf-secrets`
#   Linode      — var.linode_api_token, rendered into secrets.auto.tfvars from 1Password by `make tf-secrets`

provider "aws" {
  profile = "oaf-legacy"
  region  = var.ec2_region
}

provider "aws" {
  alias   = "us-east-1"
  profile = "oaf-legacy"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "ap-southeast-1"
  profile = "oaf-legacy"
  region  = "ap-southeast-1"
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
