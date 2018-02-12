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

# Get the AMI for Ubuntu 16.04. Lock it to a specific version so that we don't
# keep re-provisioning the servers when the AMI gets updated
data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180205"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Canonical
  owners = ["099720109477"]
}

resource "aws_instance" "theyvoteforyou" {
  ami =  "${data.aws_ami.ubuntu.id}"
  # t2.micro doesn't give us enough memory
  instance_type = "t2.small"
  key_name = "test"
  tags {
    Name = "theyvoteforyou"
  }
  security_groups = ["${aws_security_group.theyvoteforyou.name}"]
}

resource "aws_eip" "theyvoteforyou" {
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
  # kedumba has a 150GB disk so let's start with 50GB of database
  allocated_storage          = 50
  # Using general purpose SSD
  storage_type               = "gp2"
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
  multi_az                   = true
  auto_minor_version_upgrade = true
  # TODO: Switch to false for production use
  apply_immediately          = true
  skip_final_snapshot        = false
  vpc_security_group_ids = ["${aws_security_group.main_database.id}"]
}

resource "aws_security_group" "main_database" {
  name        = "main_database"
  description = "main database security group"

  # TODO: Limit ingoing and outgoing traffic to within our vpc
  ingress {
    from_port   = 3306
    to_port     = 3306
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
  value       = "${aws_eip.theyvoteforyou.public_ip}"
  ttl         = 60
  gtdLocation = "DEFAULT"
}

resource "dme_record" "test_ec2" {
  # theyvoteforyou.org.au
  domainid    = "1828502"
  type        = "CNAME"
  name        = "test.ec2"
  value       = "ec2"
  ttl         = 60
  gtdLocation = "DEFAULT"
}

resource "dme_record" "www_ec2" {
  # theyvoteforyou.org.au
  domainid    = "1828502"
  type        = "CNAME"
  name        = "www.ec2"
  value       = "ec2"
  ttl         = 60
  gtdLocation = "DEFAULT"
}

resource "dme_record" "www_test_ec2" {
  # theyvoteforyou.org.au
  domainid    = "1828502"
  type        = "CNAME"
  name        = "www.test.ec2"
  value       = "ec2"
  ttl         = 60
  gtdLocation = "DEFAULT"
}
