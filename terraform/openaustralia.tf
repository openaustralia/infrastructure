resource "aws_instance" "openaustralia" {
  ami =  "${data.aws_ami.ubuntu.id}"
  # TODO: For production increase this to something sensible
  instance_type = "t2.small"
  key_name = "test"
  tags {
    Name = "openaustralia"
  }
  security_groups = ["${aws_security_group.webserver.name}"]
  # TODO: For production enable this
  disable_api_termination = false
}

resource "aws_eip" "openaustralia" {
  instance = "${aws_instance.openaustralia.id}"
  tags {
    Name = "openaustralia"
  }
}
