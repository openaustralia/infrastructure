# (We're still using Ansible for configuring the servers themselves and
# the normal application deployment is still done with capistrano)

resource "aws_instance" "theyvoteforyou" {
  ami =  "${data.aws_ami.ubuntu.id}"
  # t2.small was running at 100% cpu on the production load (due to the ruby web
  # processes) and was failing to index elasticsearch (probably because of memory)
  instance_type = "t2.medium"
  key_name = "test"
  tags {
    Name = "theyvoteforyou"
  }
  security_groups = ["${aws_security_group.theyvoteforyou.name}"]
  disable_api_termination = true
}

resource "aws_eip" "theyvoteforyou" {
  instance = "${aws_instance.theyvoteforyou.id}"
}

data "aws_security_group" "default" {
  name = "default"
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

  # TODO: Remove this once migration is complete and we don't
  # need the ssh tunnel running on theyvoteforyou
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${data.aws_security_group.default.id}"]
  }

  # Allow everything going out
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
