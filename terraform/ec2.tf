# An experiment in setting up the OAF infrastructure on EC2 using terraform
# (We're still using Ansible for configuring the servers themselves and
# the normal application deployment is still done with capistrano)

# Configure the AWS Provider
provider "aws" {
  version = "~> 1.8"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.ec2_region}"
}

resource "aws_instance" "theyvoteforyou" {
  # Ubuntu 16.04 in Sydney
  ami =  "ami-974eb0f5"
  # t2.micro doesn't give us enough memory
  instance_type = "t2.small"
  key_name = "test"
  tags {
    Name = "theyvoteforyou"
  }
  security_groups = ["${aws_security_group.theyvoteforyou.name}"]
}

resource "aws_security_group" "theyvoteforyou" {
  name        = "theyvoteforyou"
  description = "theyvoteforyou security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
