resource "aws_instance" "metabase" {
  ami = var.ubuntu_22_ami

  instance_type = "t3.small"
  ebs_optimized = true
  key_name      = "deployer_key"
  tags = {
    Name = "metabase"
  }
  # This security group also lets in port 9000 for staging which we're not using
  security_groups = [aws_security_group.planningalerts.name]

  # disable_api_termination = true
  iam_instance_profile = aws_iam_instance_profile.logging.name
}

resource "aws_eip" "metabase" {
  instance = aws_instance.metabase.id
  tags = {
    Name = "metabase"
  }
}
