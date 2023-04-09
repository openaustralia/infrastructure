resource "aws_s3_bucket" "main" {
  bucket = "planningalerts-as-${var.env}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "main" {
  name = "planningalerts-as-${var.env}"
}

resource "aws_iam_access_key" "main" {
  user = aws_iam_user.main.name
}
