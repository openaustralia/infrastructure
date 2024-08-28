resource "aws_s3_bucket" "sitemaps" {
  bucket = "planningalerts-sitemaps-production"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sitemaps" {
  bucket = aws_s3_bucket.sitemaps.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_user" "sitemaps" {
  name = "planningalerts-sitemaps-production"
}

resource "aws_iam_access_key" "sitemaps" {
  user = aws_iam_user.sitemaps.name
}

resource "aws_iam_user_policy" "upload_to_sitemaps" {
  user = aws_iam_user.sitemaps.name
  name = "upload"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:PutObject",
            "s3:PutObjectAcl",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:s3:::${aws_s3_bucket.sitemaps.bucket}/*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}
