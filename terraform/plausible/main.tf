resource "aws_instance" "main" {
  ami = var.ami

  instance_type = "t3.small"
  ebs_optimized = true
  key_name      = "deployer_key"
  tags = {
    Name = "plausible"
  }
  security_groups = [var.security_group_behind_lb.name]

  # TODO: Uncomment this for production
  # disable_api_termination = true
  iam_instance_profile = var.instance_profile.name
}

