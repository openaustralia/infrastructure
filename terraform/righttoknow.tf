resource "aws_instance" "righttoknow" {
  ami =  "${data.aws_ami.ubuntu.id}"
  # Changed it from t2.small to t2.medium because provisioning was very slow
  instance_type = "t2.medium"
  key_name = "test"
  tags {
    Name = "righttoknow"
  }
  security_groups = [
    "${aws_security_group.webserver.name}",
    "${aws_security_group.incoming_email.name}"
  ]
  availability_zone = "${aws_ebs_volume.righttoknow_data.availability_zone}"
  # TODO: For production set disable_api_termination to true
  disable_api_termination = false
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
    size = 20
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
