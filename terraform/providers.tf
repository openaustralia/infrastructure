# Provider credentials come from each operator's CLI tooling, not tfvars:
#   AWS         — `~/.aws/credentials`, AWS_PROFILE, AWS SSO, instance profile
#   Cloudflare  — CLOUDFLARE_API_TOKEN env var
#   Linode      — LINODE_TOKEN env var
#   Google      — `gcloud auth application-default login`

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

provider "cloudflare" {}

provider "google" {
  project               = "planningalerts-214303"
  region                = "australia-southeast1"
  zone                  = "australia-southeast1-a"
  user_project_override = true
  billing_project       = "planningalerts-214303"
}

provider "linode" {}
