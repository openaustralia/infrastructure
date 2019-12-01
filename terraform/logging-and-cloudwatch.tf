resource "aws_iam_role" "logging" {
  # TODO: Don't know yet if this is a sensible name or not
  name               = "logging"
  description        = "Allows EC2 instances to send logs"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "logging" {
  role   = aws_iam_role.logging.name
  name   = "logging"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_instance_profile" "logging" {
  name = "logging"
  role = aws_iam_role.logging.name
}

# TODO: Setup retention settings on logs
