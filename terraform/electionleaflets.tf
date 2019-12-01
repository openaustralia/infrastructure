data "external" "id_rsa" {
  program = ["./prepkey.sh"]
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer_key"
  public_key = "${data.external.id_rsa.result["id_rsa"]}"
}

resource "aws_instance" "electionleaflets" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.small"
  key_name      = "deployer_key"
  tags {
    Name = "electionleaflets"
  }
  security_groups         = ["${aws_security_group.webserver.name}"]
  availability_zone       = "${aws_ebs_volume.electionleaflets_data.availability_zone}"
  disable_api_termination = true
  iam_instance_profile    = "${aws_iam_instance_profile.logging.name}"
}

resource "aws_eip" "electionleaflets" {
  instance = "${aws_instance.electionleaflets.id}"
  tags {
    Name = "electionleaflets"
  }
}

# We'll create a seperate EBS volume for all the application
# data that can not be regenerated. e.g. parliamentary XML,
# register of members interests scans, etc..

resource "aws_ebs_volume" "electionleaflets_data" {
  availability_zone = "ap-southeast-2c"

  # 10 Gb is an educated guess based on seeing how much space is taken up
  # on kedumba.
  # After loading real data in we upped it to 20GB
  size = 20
  type = "gp2"
  tags {
    Name = "electionleaflets_data"
  }
}

resource "aws_volume_attachment" "electionleaflets_data" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.electionleaflets_data.id}"
  instance_id = "${aws_instance.electionleaflets.id}"
}

# TODO: backup EBS volume by taking daily snapshots
# This can be automated using Cloudwatch. See:
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/TakeScheduledSnapshot.html
# https://www.terraform.io/docs/providers/aws/r/cloudwatch_event_rule.html

resource "aws_iam_user" "electionleaflets" {
  name = "electionleaflets"
}

resource "aws_iam_policy" "electionleaflets" {
  name   = "S3BucketAccessTo_electionleafletsaustralia"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:HeadBucket",
                "s3:ListObjects"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::electionleafletsaustralia",
                "arn:aws:s3:::electionleafletstest2",
                "arn:aws:s3:::electionleafletsaustralia/*",
                "arn:aws:s3:::electionleafletstest2/*"
            ]
        }
    ]
}
EOF

}

resource "aws_iam_user_policy_attachment" "electionleaflets" {
  user       = "${aws_iam_user.electionleaflets.name}"
  policy_arn = "${aws_iam_policy.electionleaflets.arn}"
}

resource "aws_s3_bucket" "production" {
  provider = "aws.ap-southeast-1"
  bucket   = "electionleafletsaustralia"
  region   = "ap-southeast-1"

  # We don't want to use the pre-canned "public-read" because this allows listing
  # of all the objects in the bucket. There might be hidden leaflets. So, we
  # don't want to allow this.
  # TODO: Figure out how to set the proper permissions using the acl for the bucket
  acl = ""
}

resource "aws_s3_bucket" "staging" {
  provider = "aws.ap-southeast-1"
  bucket   = "electionleafletstest2"
  region   = "ap-southeast-1"

  # We don't want to use the pre-canned "public-read" because this allows listing
  # of all the objects in the bucket. There might be hidden leaflets. So, we
  # don't want to allow this.
  # TODO: Figure out how to set the proper permissions using the acl for the bucket
  acl = ""
}
