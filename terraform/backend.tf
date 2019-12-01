# We're storing the terraform state in S3
terraform {
  backend "s3" {
    bucket  = "oaf-terraform-state"
    key     = "terraform-state"
    region  = "ap-southeast-2"
    encrypt = true
  }
}

# The S3 bucket for storing terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "oaf-terraform-state"
  acl    = "private"

  versioning {
    enabled = true
  }
}
