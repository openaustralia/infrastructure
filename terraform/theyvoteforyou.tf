# (We're still using Ansible for configuring the servers themselves and
# the normal application deployment is still done with capistrano)

resource "aws_instance" "theyvoteforyou" {
  ami = var.ubuntu_20_ami

  instance_type = "t3.large"
  ebs_optimized = true
  key_name      = aws_key_pair.deployer.key_name
  tags = {
    Name = "theyvoteforyou"
  }
  security_groups         = [aws_security_group.webserver.name]
  disable_api_termination = true
  iam_instance_profile    = aws_iam_instance_profile.logging.name
  # Setting the availability zone because it needs to be the same as the disk
  availability_zone       = "ap-southeast-2a"
}

resource "aws_eip" "theyvoteforyou" {
  instance = aws_instance.theyvoteforyou.id
  tags = {
    Name = "theyvoteforyou"
  }
}

resource "aws_ebs_volume" "theyvoteforyou_data" {
  availability_zone = aws_instance.theyvoteforyou.availability_zone

  size = 30
  type = "gp3"
  tags = {
    Name = "theyvoteforyou_data"
  }
}

resource "aws_volume_attachment" "theyvoteforyou_data" {
  device_name = "/dev/sdi"
  volume_id   = aws_ebs_volume.theyvoteforyou_data.id
  instance_id = aws_instance.theyvoteforyou.id
}
