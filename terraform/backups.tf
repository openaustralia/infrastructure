resource "aws_iam_user" "oaf-backups" {
  name = "oaf-backups"
}

resource "aws_iam_policy" "oaf-backups" {
  name   = "S3BucketAccessTo_oaf-backups"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::oaf-backups"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::oaf-backups/*"
        }
    ]
}
EOF

}

resource "aws_iam_user_policy_attachment" "oaf-backups" {
  user       = aws_iam_user.oaf-backups.name
  policy_arn = aws_iam_policy.oaf-backups.arn
}

resource "aws_s3_bucket" "oaf-backups" {
  provider = aws.us-east-1
  bucket   = "oaf-backups"
  region   = "us-east-1"
  acl      = "private"
}
