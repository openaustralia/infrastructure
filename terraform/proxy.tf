resource "aws_instance" "au_proxy" {
  ami = "${data.aws_ami.ubuntu.id}"
  # Keeping this as small as we possibly can
  instance_type = "t2.nano"
  key_name      = "deployer_key"
  tags {
    Name = "au.proxy"
  }
  security_groups = ["${aws_security_group.proxy.name}"]
  # disable_api_termination = true
  iam_instance_profile = "${aws_iam_instance_profile.logging.name}"
}

resource "aws_eip" "au_proxy" {
  instance = "${aws_instance.au_proxy.id}"
  tags {
    Name = "au.proxy"
  }
}
