resource "aws_instance" "righttoknow" {
  ami =  "${data.aws_ami.ubuntu.id}"
  # Changed it from t2.small to t2.medium because provisioning was very slow
  instance_type = "t2.medium"
  key_name = "test"
  tags {
    Name = "righttoknow"
  }
  security_groups = [
    "${aws_security_group.webserver.name}",
    "${aws_security_group.incoming_email.name}"
  ]
  # TODO: For production set disable_api_termination to true
  disable_api_termination = false
}

resource "aws_eip" "righttoknow" {
  instance = "${aws_instance.righttoknow.id}"
  tags {
    Name = "righttoknow"
  }
}
