resource "aws_iam_user" "oaf-backups" {
  name = "oaf-backups"
}

data "aws_iam_policy_document" "oaf-backups" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListAllMyBuckets",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::oaf-backups",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::oaf-backups/*",
    ]
  }
}

resource "aws_iam_policy" "oaf-backups" {
  name   = "S3BucketAccessTo_oaf-backups"
  policy = data.aws_iam_policy_document.oaf-backups.json
}

resource "aws_iam_user_policy_attachment" "oaf-backups" {
  user       = aws_iam_user.oaf-backups.name
  policy_arn = aws_iam_policy.oaf-backups.arn
}

resource "aws_s3_bucket" "oaf-backups" {
  provider = aws.us-east-1
  bucket   = "oaf-backups"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "oaf-backups" {
  provider = aws.us-east-1
  bucket   = aws_s3_bucket.oaf-backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "oaf-backups" {
  provider = aws.us-east-1
  bucket   = aws_s3_bucket.oaf-backups.id

  acl = "private"
}
