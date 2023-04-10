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
  bucket                  = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_user_policy" "main" {
  user   = aws_iam_user.main.name
  policy = jsonencode(
    {
      Statement = [
        {
          Action   = [
            "s3:ListBucket",
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:s3:::${aws_s3_bucket.main.id}/*"
        },
      ]
      Version   = "2012-10-17"
    }
  )
}

resource "aws_iam_access_key" "main" {
  user = aws_iam_user.main.name
}
