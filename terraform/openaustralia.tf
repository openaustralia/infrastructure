resource "aws_instance" "openaustralia" {
  ami =  "${data.aws_ami.ubuntu.id}"
  # TODO: For production increase this to something sensible
  instance_type = "t2.small"
  key_name = "test"
  tags {
    Name = "openaustralia"
  }
  security_groups = ["${aws_security_group.webserver.name}"]
  # TODO: For production enable this
  disable_api_termination = false
}

resource "aws_eip" "openaustralia" {
  instance = "${aws_instance.openaustralia.id}"
  tags {
    Name = "openaustralia"
  }
}

# We'll create a seperate EBS volume for all the application
# data that can not be regenerated. e.g. parliamentary XML,
# register of members interests scans, etc..

resource "aws_ebs_volume" "openaustralia_data" {
    availability_zone = "${aws_instance.openaustralia.availability_zone}"
    # 10 Gb is an educated guess based on seeing how much space is taken up
    # on kedumba.
    # TODO: This might need to be increased for production
    size = 10
    type = "gp2"
    tags {
        Name = "openaustralia_data"
    }
}

resource "aws_volume_attachment" "openaustralia_data" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.openaustralia_data.id}"
  instance_id = "${aws_instance.openaustralia.id}"
}

# TODO: backup EBS volume by taking daily snapshots
# This can be automated using Cloudwatch. See:
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/TakeScheduledSnapshot.html
# https://www.terraform.io/docs/providers/aws/r/cloudwatch_event_rule.html
