resource "aws_iam_role" "logging" {
  # TODO: Don't know yet if this is a sensible name or not
  name = "logging"
  description = "Allows EC2 instances to send logs, and to run Cloudwatch Agent"
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
  name = "logging"
  role = "${aws_iam_role.logging.name}"
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
  name  = "logging"
  role = "${aws_iam_role.logging.name}"
}

resource "aws_iam_role" "CloudWatchAgentServerRole" {
  name = "CloudWatchAgentServerRole"
  description = "Allows an EC2 instance to run CloudWatch agent"
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


resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerRole-CWAServerPolicy"
{
  role = "${aws_iam_role.CloudWatchAgentServerRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

#Each instance can only have one role; all instances currently have the logging role
#So we'll tack the CloudWatchAgentServer requirements into that role

resource "aws_iam_role_policy_attachment" "logging-CWAServerPolicy"
{
  role = "${aws_iam_role.logging.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


resource "aws_iam_role" "CloudWatchAgentAdminRole" {
  name = "CloudWatchAgentAdminRole"
  description = "Allows a server to write CloudWatch configs to Parameter Store. Should only be applied to the server where configs are being written, and only while the config is actively being updated. After you are finished creating the agent configuration file you should detach this role from the instance and use the CloudWatchAgentServerPolicy instead."
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

resource "aws_iam_role_policy_attachment" "CloudWatchAgentAdminRole-CWAAdminPolicy"
{
  role = "${aws_iam_role.CloudWatchAgentAdminRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
}


# TODO: Setup retention settings on logs
