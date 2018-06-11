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

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerRole-EC2SSM"
{
  role = "${aws_iam_role.CloudWatchAgentServerRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerRole-CWAServerPolicy"
{
  role = "${aws_iam_role.CloudWatchAgentServerRole.name}"
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

resource "aws_iam_role_policy_attachment" "CloudWatchAgentAdminRole-EC2SSM"
{
  role = "${aws_iam_role.CloudWatchAgentAdminRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
