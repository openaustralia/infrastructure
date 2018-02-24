resource "aws_instance" "jamison" {
  ami =  "ami-02211161"
  instance_type = "t2.small"
  tags {
    Name = "jamison"
  }
  security_groups = ["${aws_security_group.jamison.name}"]
  disable_api_termination = true
}

resource "aws_eip" "jamison" {
  instance = "${aws_instance.jamison.id}"
  tags {
    Name = "jamison"
  }
}

resource "aws_instance" "kedumba" {
  ami = "ami-33ab5251"
  instance_type = "t2.large"
  tags {
    Name = "kedumba"
  }
  security_groups = ["${aws_security_group.kedumba.name}"]
  disable_api_termination = true
}

resource "aws_eip" "kedumba" {
  instance = "${aws_instance.kedumba.id}"
  tags {
    Name = "kedumba"
  }
}
