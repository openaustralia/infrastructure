resource "aws_instance" "planningalerts" {
  ami =  "${data.aws_ami.ubuntu.id}"
  # A quick look at newrelic is showing PlanningAlerts on kedumba
  # using about 1.5GB. A medium instance gives us 4GB
  # We t2.medium we were running out of memory when the scraping and emailing
  # setup happens at 12pm. There was also a bug which was causing multiple
  # instances of this to run at the same time until the memory was exhausted
  # and the server crashed. So, upped the instance size just to be on the
  # safe size.
  # After a couple of days of seeing the memory behaviour around 12pm
  # with the new instance size we realised we could in fact move back down
  # to the smaller t2.medium.
  # After moving to sidekiq we seem to be needing some more memory.
  # So increased the instance type to t2.large.
  # TODO: It would be good to check if we can go smaller again
  instance_type = "t2.large"
  key_name = "test"
  tags {
    Name = "planningalerts"
  }
  security_groups = ["${aws_security_group.webserver.name}"]
  disable_api_termination = true
  iam_instance_profile = "${aws_iam_instance_profile.logging.name}"
}

resource "aws_eip" "planningalerts" {
  instance = "${aws_instance.planningalerts.id}"
  tags {
    Name = "planningalerts"
  }
}
