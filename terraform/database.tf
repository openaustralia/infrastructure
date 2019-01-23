resource "aws_db_instance" "main" {
  # kedumba has a 150GB disk so let's start with 50GB of database
  allocated_storage          = 50
  # Using general purpose SSD
  storage_type               = "gp2"
  engine                     = "mysql"
  engine_version             = "5.6.37"
  # 1. We went from db.t2.small to db.t2.medium before we discovered that the
  #    database migration service hadn't migrated the databases indexes. Oops!!
  #    We might be able to go back down to small in the short term but would
  #    rather leave us with spare capacity in the short term while we iron out
  #    the kinks rather than dashing around upping capacity to debug problems.
  # 2. With db.t2.medium it turned out we were running out of cpu credits
  #    after a few days. So, upping to db.m4.large as the smallest "standard"
  #    database instance
  instance_class             = "db.m4.large"
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
  apply_immediately          = false
  skip_final_snapshot        = false
  vpc_security_group_ids     = ["${aws_security_group.main_database.id}"]
  parameter_group_name       = "${aws_db_parameter_group.mysql_default.name}"
}

# TODO: Do we want to explicitly set the available zone?
resource "aws_db_instance" "postgresql" {
  # Backup of righttoknow database was about 18GB. So, let's start with 50
  # like we did with the mysql database
  allocated_storage          = 50
  # Using general purpose SSD
  storage_type               = "gp2"
  engine                     = "postgres"
  engine_version             = "9.4.15"
  # Let's start in production with db.t2.medium. We should watch the cpu credits
  # Dropping down to db.t2.small because we're under-using
  instance_class             = "db.t2.small"
  identifier                 = "postgresql"
  username                   = "root"
  password                   = "${var.rds_admin_password}"
  publicly_accessible        = false
  backup_retention_period    = 35
  # We want 3-3:30am Sydney time which is 4-4:30pm GMT
  backup_window              = "16:00-16:30"
  # We want Monday 4-4:30am Sydney time which is Sunday 5-5:30pm GMT.
  maintenance_window         = "Sun:17:00-Sun:17:30"
  multi_az = true
  auto_minor_version_upgrade = true
  # TODO: For production change apply_immediately to false
  apply_immediately          = true
  skip_final_snapshot        = false
  vpc_security_group_ids     = ["${aws_security_group.postgresql.id}"]
}

# Allow triggers on mysql
resource "aws_db_parameter_group" "mysql_default" {
  name   = "allow-triggers"
  description = "Allows triggers on mysql"
  family = "mysql5.6"

  parameter {
    name  = "log_bin_trust_function_creators"
    value = 1
    apply_method = "pending-reboot"
  }
}
