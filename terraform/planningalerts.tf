resource "aws_instance" "planningalerts" {
  ami =  "${data.aws_ami.ubuntu.id}"
  # A quick look at newrelic is showing PlanningAlerts on kedumba
  # using about 1.5GB. A medium instance gives us 4GB
  # We t2.medium we were running out of memory when the scraping and emailing
  # setup happens at 12pm. There was also a bug which was causing multiple
  # instances of this to run at the same time until the memory was exhausted
  # and the server crashed. So, upped the instance size just to be on the
  # safe size.
  # TODO: Check if we can safely go back down to t2.medium
  instance_type = "t2.large"
  key_name = "test"
  tags {
    Name = "planningalerts"
  }
  security_groups = ["${aws_security_group.webserver.name}"]
  disable_api_termination = true
}

resource "aws_eip" "planningalerts" {
  instance = "${aws_instance.planningalerts.id}"
  tags {
    Name = "planningalerts"
  }
}
