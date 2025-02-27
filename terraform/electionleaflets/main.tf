terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4.0"
    }
  }
}

provider "aws" {
  alias  = "ap-southeast-1"
  region = "ap-southeast-1"
}

resource "aws_instance" "main" {
  ami           = var.ami
  instance_type = "t3.nano"
  ebs_optimized = true
  key_name      = "deployer_key"
  tags = {
    Name = "electionleaflets"
  }
  security_groups         = [var.security_group.name]
  availability_zone       = aws_ebs_volume.data.availability_zone
  disable_api_termination = true
  iam_instance_profile    = var.instance_profile.name
}

resource "aws_eip" "electionleaflets" {
  instance = aws_instance.main.id
  tags = {
    Name = "electionleaflets"
  }
}

# We'll create a seperate EBS volume for all the application
# data that can not be regenerated. e.g. parliamentary XML,
# register of members interests scans, etc..

resource "aws_ebs_volume" "data" {
  availability_zone = "ap-southeast-2c"

  # 10 Gb is an educated guess based on seeing how much space is taken up
  # on kedumba.
  # After loading real data in we upped it to 20GB
  size = 20
  type = "gp3"
  tags = {
    Name = "electionleaflets_data"
  }
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.main.id
}

# TODO: backup EBS volume by taking daily snapshots
# This can be automated using Cloudwatch. See:
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/TakeScheduledSnapshot.html
# https://www.terraform.io/docs/providers/aws/r/cloudwatch_event_rule.html

resource "aws_iam_user" "main" {
  name = "electionleaflets"
}

resource "aws_iam_policy" "main" {
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

resource "aws_iam_user_policy_attachment" "main" {
  user       = aws_iam_user.main.name
  policy_arn = aws_iam_policy.main.arn
}

data "aws_canonical_user_id" "current_user" {}

# TODO: Extract production and staging bucket configuration into module

resource "aws_s3_bucket" "production" {
  provider = aws.ap-southeast-1
  bucket   = "electionleafletsaustralia"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "production" {
  provider = aws.ap-southeast-1
  bucket   = aws_s3_bucket.production.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "production" {
  provider = aws.ap-southeast-1
  bucket   = aws_s3_bucket.production.id

  # We don't want to use the pre-canned "public-read" because this allows listing
  # of all the objects in the bucket. There might be hidden leaflets. So, we
  # don't want to allow this.
  # TODO: Figure out how to set the proper permissions using the acl for the bucket
  # acl = "public-read"

  access_control_policy {
    grant {
      permission = "READ_ACP"

      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/global/AllUsers"
      }
    }
    grant {
      permission = "FULL_CONTROL"

      grantee {
        id   = data.aws_canonical_user_id.current_user.id
        type = "CanonicalUser"
      }
    }

    owner {
      id = data.aws_canonical_user_id.current_user.id
    }
  }
}

resource "aws_s3_bucket" "staging" {
  provider = aws.ap-southeast-1
  bucket   = "electionleafletstest2"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "staging" {
  provider = aws.ap-southeast-1
  bucket   = aws_s3_bucket.staging.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "staging" {
  provider = aws.ap-southeast-1
  bucket   = aws_s3_bucket.staging.id

  # We don't want to use the pre-canned "public-read" because this allows listing
  # of all the objects in the bucket. There might be hidden leaflets. So, we
  # don't want to allow this.
  # TODO: Figure out how to set the proper permissions using the acl for the bucket
  # acl = "public-read"

  access_control_policy {
    grant {
      permission = "READ_ACP"

      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/global/AllUsers"
      }
    }
    grant {
      permission = "FULL_CONTROL"

      grantee {
        id   = data.aws_canonical_user_id.current_user.id
        type = "CanonicalUser"
      }
    }

    owner {
      id = data.aws_canonical_user_id.current_user.id
    }
  }
}
