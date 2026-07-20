data "aws_iam_policy_document" "logging_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "logging" {
  # TODO: Don't know yet if this is a sensible name or not
  name               = "logging"
  description        = "Allows EC2 instances to send logs"
  assume_role_policy = data.aws_iam_policy_document.logging_assume_role.json
}

data "aws_iam_policy_document" "logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }
}

# Attach inline policy to role to grant logs:* permissions directly (no other reference needed)
resource "aws_iam_role_policy" "logging" {
  role   = aws_iam_role.logging.name
  name   = "logging"
  policy = data.aws_iam_policy_document.logging.json
}

resource "aws_iam_instance_profile" "logging" {
  name = "logging"
  role = aws_iam_role.logging.name
}

# TODO: Setup retention settings on logs
