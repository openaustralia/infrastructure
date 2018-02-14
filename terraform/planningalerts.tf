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
