resource "aws_instance" "planningalerts" {
  ami =  "${data.aws_ami.ubuntu.id}"
  # A quick look at newrelic is showing PlanningAlerts on kedumba
  # using about 1.5GB. A medium instance gives us 4GB
  instance_type = "t2.medium"
  key_name = "test"
  tags {
    Name = "planningalerts"
  }
  security_groups = ["${aws_security_group.webserver.name}"]
  disable_api_termination = true
}

resource "aws_eip" "planningalerts" {
  instance = "${aws_instance.planningalerts.id}"
}
