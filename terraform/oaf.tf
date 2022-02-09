resource "aws_instance" "oaf" {
  # This has been upgraded in place to Ubuntu 18.04
  ami           = var.ubuntu_16_ami
  instance_type = "t3.small"
  ebs_optimized = true
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
