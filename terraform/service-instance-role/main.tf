data "aws_iam_policy_document" "assume_role" {
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

resource "aws_iam_role" "this" {
  name               = var.service_name
  description        = "EC2 instances for ${var.service_name}: CloudWatch Logs and SSM Session Manager access"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
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

resource "aws_iam_role_policy" "cloudwatch_logging" {
  role   = aws_iam_role.this.name
  name   = "cloudwatch-logging"
  policy = data.aws_iam_policy_document.cloudwatch_logging.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "extra" {
  count  = var.extra_policy_json == null ? 0 : 1
  role   = aws_iam_role.this.name
  name   = "${var.service_name}-extra"
  policy = var.extra_policy_json
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.service_name}-instance-profile"
  role = aws_iam_role.this.name
}
