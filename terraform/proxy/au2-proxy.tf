resource "aws_instance" "au2" {
  ami           = var.ubuntu_22_ami

  # Keeping this as small as we possibly can
  instance_type = "t3.nano"
  ebs_optimized = true
  key_name      = "deployer_key"
  tags = {
    Name = "au2.proxy"
  }
  security_groups = [aws_security_group.main.name]

  # disable_api_termination = true
  iam_instance_profile = var.instance_profile.name
}

resource "aws_eip" "au2" {
  instance = aws_instance.au2.id
  tags = {
    Name = "au2.proxy"
  }
}
