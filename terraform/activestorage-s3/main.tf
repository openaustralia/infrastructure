# Creates an S3 bucket that is configured for use by rails active storage

resource "aws_s3_bucket" "main" {
  bucket = var.name
}

resource "aws_iam_user" "main" {
  name = var.name
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
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  # Example configuration from https://guides.rubyonrails.org/active_storage_overview.html#example-s3-cors-configuration
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    allowed_origins = var.allowed_origins
    expose_headers  = ["Origin", "Content-Type", "Content-MD5", "Content-Disposition"]
    max_age_seconds = 3600
  }
}

resource "aws_iam_user_policy" "main" {
  user = aws_iam_user.main.name
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:ListBucket",
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:s3:::${aws_s3_bucket.main.id}/*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_access_key" "main" {
  user = aws_iam_user.main.name
}
