provider "aws" {
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
  api_token = var.cloudflare_api_token
}

# To use this provider we authenticate with:
# gcloud auth application-default login
provider "google" {
  project               = "planningalerts-214303"
  region                = "australia-southeast1"
  zone                  = "australia-southeast1-a"
  user_project_override = true
  billing_project       = "planningalerts-214303"
}
