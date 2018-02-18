resource "aws_instance" "jamison" {
  ami =  "ami-02211161"
  instance_type = "t2.small"
  tags {
    Name = "jamison"
  }
  security_groups = ["${aws_security_group.jamison.name}"]
}

resource "aws_eip" "jamison" {
  instance = "${aws_instance.jamison.id}"
}
