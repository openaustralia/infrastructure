# TODO: We can remove jamison pretty soon now
resource "aws_instance" "jamison" {
  ami =  "ami-02211161"
  instance_type = "t2.small"
  tags {
    Name = "jamison"
  }
  security_groups = ["${aws_security_group.jamison.name}"]
  disable_api_termination = false
}

resource "aws_instance" "kedumba" {
  ami = "ami-33ab5251"
  # There's only a few services left on kedumba, the biggest
  # one being righttoknow. So, we can drop the instance size down
  # from t2.large to t2.medium
  # Moved it to t2.small when oaf.org.au was moved off
  instance_type = "t2.small"
  tags {
    Name = "kedumba"
  }
  security_groups = ["${aws_security_group.kedumba.name}"]
  disable_api_termination = false
}
