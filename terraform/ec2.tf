# An experiment in setting up the OAF infrastructure on EC2 using terraform
# (We're still using Ansible for configuring the servers themselves and
# the normal application deployment is still done with capistrano)

# Configure the AWS Provider
provider "aws" {
  version = "~> 1.8"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.ec2_region}"
}

# TODO: Don't hardcode ami but rather look it up

resource "aws_instance" "theyvoteforyou" {
  # Ubuntu 16.04 in Sydney
  ami =  "ami-974eb0f5"
  # t2.micro doesn't give us enough memory
  instance_type = "t2.small"
  key_name = "test"
  tags {
    Name = "theyvoteforyou"
  }
  security_groups = ["${aws_security_group.theyvoteforyou.name}"]
}

# TODO: Rename
resource "aws_eip" "bar" {
  instance = "${aws_instance.theyvoteforyou.id}"
}

resource "aws_security_group" "theyvoteforyou" {
  name        = "theyvoteforyou"
  description = "theyvoteforyou security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow everything going out
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "main" {
  # Start with 10GB of storage
  allocated_storage          = 10
  # Using magnetic just for testing/development
  # TODO: For production use SSD for storage type
  storage_type               = "standard"
  engine                     = "mysql"
  engine_version             = "5.6.37"
  # This instance type is only for testing/development
  instance_class             = "db.t2.small"
  identifier                 = "main-database"
  username                   = "admin"
  password                   = "${var.rds_admin_password}"
  publicly_accessible        = false
  # Keep backups around for one week
  backup_retention_period    = 7
  # We want 3-3:30am Sydney time which is 4-4:30pm GMT
  backup_window              = "16:00-16:30"
  # We want Monday 4-4:30am Sydney time which is Sunday 5-5:30pm GMT.
  maintenance_window         = "Sun:17:00-Sun:17:30"
  # TODO: Change this to true for production
  multi_az                   = false
  auto_minor_version_upgrade = true
  # TODO: Switch to false for production use
  apply_immediately          = true
  # TODO: Set to false for production
  skip_final_snapshot        = true
}

# Configure the DNSMadeEasy provider
provider "dme" {
  version    = "~> 0.1"
  akey       = "${var.dnsmadeeasy_akey}"
  skey       = "${var.dnsmadeeasy_skey}"
  usesandbox = false
}

# Create an A record
resource "dme_record" "ec2" {
  # theyvoteforyou.org.au
  domainid    = "1828502"
  type        = "A"
  name        = "ec2"
  value       = "${aws_eip.bar.public_ip}"
  ttl         = 60
  gtdLocation = "DEFAULT"
}
