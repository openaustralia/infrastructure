# Role + instance profile granting EC2 instances CloudWatch Logs write access
# and SSM Session Manager access. Same permissions as aws_iam_role.logging in
# logging-and-cloudwatch.tf, plus AmazonSSMManagedInstanceCore.
#
# If this role's contents need to change in future, create a new role with a
# new name reflecting the new contents rather than editing this one in place —
# don't let the name silently go stale for whatever's already using it.

data "aws_iam_policy_document" "cloudwatch_logging_and_ssm_assume_role" {
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

resource "aws_iam_role" "cloudwatch_logging_and_ssm" {
  name               = "cloudwatch-logging-and-ssm"
  description        = "Allows EC2 instances to send logs to CloudWatch and be managed via SSM Session Manager"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_logging_and_ssm_assume_role.json
}

data "aws_iam_policy_document" "cloudwatch_logging" {
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

# Attach inline policy directly to role to grant logs:* permissions (no other reference needed)
resource "aws_iam_role_policy" "cloudwatch_logging" {
  role   = aws_iam_role.cloudwatch_logging_and_ssm.name
  name   = "cloudwatch-logging"
  policy = data.aws_iam_policy_document.cloudwatch_logging.json
}

# Also attach AWS maintained policy
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.cloudwatch_logging_and_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach this to
resource "aws_iam_instance_profile" "cloudwatch_logging_and_ssm" {
  name = "cloudwatch-logging-and-ssm"
  role = aws_iam_role.cloudwatch_logging_and_ssm.name
}
