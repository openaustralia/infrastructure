resource "aws_instance" "righttoknow" {
  ami =  "${data.aws_ami.ubuntu.id}"
  # Changed it from t2.small to t2.medium because provisioning was very slow
  # Changed from t2.medium to t2.large because it was running out of memory
  # when running script/rebuild-xapian-index
  instance_type = "t2.large"
  key_name = "test"
  tags {
    Name = "righttoknow"
  }
  security_groups = [
    "${aws_security_group.webserver.name}",
    "${aws_security_group.incoming_email.name}"
  ]
  availability_zone = "${aws_ebs_volume.righttoknow_data.availability_zone}"
  disable_api_termination = true
}

resource "aws_eip" "righttoknow" {
  instance = "${aws_instance.righttoknow.id}"
  tags {
    Name = "righttoknow"
  }
}

resource "aws_ebs_volume" "righttoknow_data" {
    availability_zone = "ap-southeast-2c"
    # 7.8 GB is current used on kedumba for shared/files. So, let's use 20 GB here.
    # Increased size because we're storing shared/cache on there too now.
    size = 50
    type = "gp2"
    tags {
        Name = "righttoknow_data"
    }
}

resource "aws_volume_attachment" "righttoknow_data" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.righttoknow_data.id}"
  instance_id = "${aws_instance.righttoknow.id}"
}
