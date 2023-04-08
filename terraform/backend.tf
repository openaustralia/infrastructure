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
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status     = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  acl = "private"
}