resource "aws_instance" "oaf" {
  ami =  "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.medium"
  key_name = "deployer_key"
  tags {
    Name = "oaf"
  }
  security_groups = ["${aws_security_group.webserver.name}"]
  disable_api_termination = true
  iam_instance_profile = "${aws_iam_instance_profile.logging.name}"
}

resource "aws_eip" "oaf" {
  instance = "${aws_instance.oaf.id}"
  tags {
    Name = "oaf"
  }
}

resource "aws_instance" "support_oaf" {
  ami =  "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.medium"
  key_name = "deployer_key"
  tags {
    Name = "support_oaf"
  }
  security_groups = ["${aws_security_group.webserver.name}"]
  disable_api_termination = true
  iam_instance_profile = "${aws_iam_instance_profile.logging.name}"
  root_block_device {
    volume_size = 20
  }
}

resource "aws_eip" "support_oaf" {
  instance = "${aws_instance.support_oaf.id}"
  tags {
    Name = "support_oaf"
  }
}
