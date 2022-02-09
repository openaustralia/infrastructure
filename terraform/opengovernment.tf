resource "aws_instance" "opengovernment" {
  ami = var.ubuntu_16_ami

  instance_type = "t3.micro"
  ebs_optimized = true
  key_name      = "deployer_key"
  tags = {
    Name = "opengovernment"
  }
  security_groups         = [aws_security_group.webserver.name]
  disable_api_termination = true
  iam_instance_profile    = aws_iam_instance_profile.logging.name
}

resource "aws_eip" "opengovernment" {
  instance = aws_instance.opengovernment.id
  tags = {
    Name = "opengovernment"
  }
}
