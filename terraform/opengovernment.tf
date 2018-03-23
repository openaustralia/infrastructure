resource "aws_instance" "opengovernment" {
  ami =  "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.small"
  key_name = "deployer_key"
  tags {
    Name = "opengovernment"
  }
  security_groups = ["${aws_security_group.webserver.name}"]
  disable_api_termination = true
}

resource "aws_eip" "opengovernment" {
  instance = "${aws_instance.opengovernment.id}"
  tags {
    Name = "opengovernment"
  }
}
