# (We're still using Ansible for configuring the servers themselves and
# the normal application deployment is still done with capistrano)

resource "aws_instance" "theyvoteforyou" {
  ami = var.ubuntu_20_ami

  # t2.small was running at 100% cpu on the production load (due to the ruby web
  # processes) and was failing to index elasticsearch (probably because of memory)
  instance_type = "t3.medium"
  ebs_optimized = true
  key_name      = aws_key_pair.deployer.key_name
  tags = {
    Name = "theyvoteforyou"
  }
  security_groups         = [aws_security_group.webserver.name]
  disable_api_termination = true
  iam_instance_profile    = aws_iam_instance_profile.logging.name
}

resource "aws_eip" "theyvoteforyou" {
  instance = aws_instance.theyvoteforyou.id
  tags = {
    Name = "theyvoteforyou"
  }
}
