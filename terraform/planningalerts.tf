resource "aws_instance" "planningalerts" {
  ami =  "${data.aws_ami.ubuntu.id}"
  # TODO: Bump this up for production
  instance_type = "t2.small"
  key_name = "test"
  tags {
    Name = "planningalerts"
  }
  security_groups = ["${aws_security_group.webserver.name}"]
  # TODO: Reenable this for production
  # disable_api_termination = true
}

resource "aws_eip" "planningalerts" {
  instance = "${aws_instance.planningalerts.id}"
}

# TODO Move this security group to its own file because it will be used by others
resource "aws_security_group" "webserver" {
  name        = "webserver"
  description = "standard security group for webservers. Allow ssh/http/https"

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

  # Allow everything going out
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
