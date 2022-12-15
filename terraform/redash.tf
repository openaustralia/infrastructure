resource "aws_instance" "redash" {
  # See https://redash.io/help/open-source/setup#aws
  ami = "ami-0bae8773e653a32ec"

  instance_type = "t3.small"
  ebs_optimized = true
  key_name      = "deployer_key"
  tags = {
    Name = "redash"
  }
  security_groups = [aws_security_group.webserver.name]

  # disable_api_termination = true
  iam_instance_profile = aws_iam_instance_profile.logging.name
}

resource "aws_eip" "redash" {
  instance = aws_instance.redash.id
  tags = {
    Name = "redash"
  }
}
