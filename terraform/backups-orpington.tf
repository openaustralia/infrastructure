# Backups for one of the OAF laptops orpington which is currently
# in Matthew's hands

# There is a manual step you'll need to do to be able to use this.
# Go into the AWS console to the IAM settings, find the "oaf-backups-orpington"
# user, go to the security credentials tab and then "create access key".

resource "aws_iam_user" "oaf-backups-orpington" {
  name = "oaf-backups-orpington"
}

resource "aws_iam_policy" "oaf-backups-orpington" {
  name   = "oaf-backups-orpington"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::oaf-backups-orpington"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::oaf-backups-orpington/*"
        }
    ]
}
EOF

}

resource "aws_iam_user_policy_attachment" "oaf-backups-orpington" {
  user       = aws_iam_user.oaf-backups-orpington.name
  policy_arn = aws_iam_policy.oaf-backups-orpington.arn
}

resource "aws_s3_bucket" "oaf-backups-orpington" {
  bucket   = "oaf-backups-orpington"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "oaf-backups-orpington" {
  bucket = aws_s3_bucket.oaf-backups-orpington.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "oaf-backups-orpington" {
  bucket = aws_s3_bucket.oaf-backups-orpington.id
  acl = "private"
}