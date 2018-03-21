resource "aws_instance" "oaf" {
  ami =  "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.small"
  key_name = "deployer_key"
  tags {
    Name = "oaf"
  }
  security_groups = ["${aws_security_group.webserver.name}"]
  # TODO: For production set to true
  disable_api_termination = false
}

resource "aws_eip" "oaf" {
  instance = "${aws_instance.oaf.id}"
  tags {
    Name = "oaf"
  }
}
