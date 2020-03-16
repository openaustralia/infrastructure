resource "aws_instance" "oaf" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.small"
  key_name      = "deployer_key"
  tags = {
    Name = "oaf"
  }
  security_groups         = [aws_security_group.webserver.name]
  disable_api_termination = true
  iam_instance_profile    = aws_iam_instance_profile.logging.name
}

resource "aws_eip" "oaf" {
  instance = aws_instance.oaf.id
  tags = {
    Name = "oaf"
  }
}
