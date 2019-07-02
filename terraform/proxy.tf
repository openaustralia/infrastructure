resource "aws_instance" "au_proxy" {
  # TODO: Change this
  ami =  "${data.aws_ami.ubuntu.id}"
  # Keeping this as small as we possibly can
  instance_type = "t2.nano"
  key_name = "deployer_key"
  tags {
    Name = "au.proxy"
  }
  security_groups = ["${aws_security_group.webserver.name}"]
  # disable_api_termination = true
  iam_instance_profile = "${aws_iam_instance_profile.logging.name}"
}
