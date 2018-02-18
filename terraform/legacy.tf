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

resource "aws_instance" "octopus" {
  ami = "ami-33ab5251"
  instance_type = "t2.large"
  tags {
    Name = "octopus"
  }
  security_groups = ["${aws_security_group.octopus.name}"]
  disable_api_termination = true
}

resource "aws_eip" "octopus" {
  instance = "${aws_instance.octopus.id}"
  tags {
    Name = "octopus"
  }
}
