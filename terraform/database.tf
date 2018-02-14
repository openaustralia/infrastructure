resource "aws_db_instance" "main" {
  # kedumba has a 150GB disk so let's start with 50GB of database
  allocated_storage          = 50
  # Using general purpose SSD
  storage_type               = "gp2"
  engine                     = "mysql"
  engine_version             = "5.6.37"
  # We went from db.t2.small to db.t2.medium before we discovered that the
  # database migration service hadn't migrated the databases indexes. Oops!!
  # We might be able to go back down to small in the short term but would
  # rather leave us with spare capacity in the short term while we iron out
  # the kinks rather than dashing around upping capacity to debug problems.
  instance_class             = "db.t2.medium"
  identifier                 = "main-database"
  username                   = "admin"
  password                   = "${var.rds_admin_password}"
  publicly_accessible        = false
  # Put the backup retention period to its maximum until we figure out what's a
  # good overall backup scheme
  # TODO: Set this to its final value
  backup_retention_period    = 35
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
