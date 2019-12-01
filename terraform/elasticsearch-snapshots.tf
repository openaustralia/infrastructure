# Add an access key for the IAM user oaf-elasticsearch-snapshots by hand (in
# the AWS console) and add it to the Ansible config in group_vars/all.yml as
# elasticsearch_snapshot_access_key and elasticsearch_snapshot_secret_key

resource "aws_iam_user" "oaf-elasticsearch-snapshots" {
  name = "oaf-elasticsearch-snapshots"
}

resource "aws_iam_policy" "oaf-elasticsearch-snapshots" {
  name   = "S3BucketAccessTo_oaf-elasticsearch-snapshots"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.oaf-elasticsearch-snapshots.id}",
        "arn:aws:s3:::${aws_s3_bucket.oaf-elasticsearch-snapshots.id}/*"
      ]
    }
  ]
}
EOF

}

resource "aws_iam_user_policy_attachment" "oaf-elasticsearch-snapshots" {
  user       = aws_iam_user.oaf-elasticsearch-snapshots.name
  policy_arn = aws_iam_policy.oaf-elasticsearch-snapshots.arn
}

resource "aws_s3_bucket" "oaf-elasticsearch-snapshots" {
  bucket = "oaf-elasticsearch-snapshots"
  acl    = "private"
}
