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
}

# TODO: Do we want to explicitly set the available zone?
resource "aws_db_instance" "postgresql" {
  # Storage is currently set to the minimum
  # TODO: For production increase storage
  allocated_storage          = 20
  # Using general purpose SSD
  storage_type               = "gp2"
  engine                     = "postgres"
  engine_version             = "9.4.15"
  # TODO: For production change this to something sensible
  instance_class             = "db.t2.micro"
  identifier                 = "postgresql"
  username                   = "root"
  password                   = "${var.rds_admin_password}"
  publicly_accessible        = false
  # TODO: For production increase backup_retention_period to 35
  backup_retention_period    = 1
  # We want 3-3:30am Sydney time which is 4-4:30pm GMT
  backup_window              = "16:00-16:30"
  # We want Monday 4-4:30am Sydney time which is Sunday 5-5:30pm GMT.
  maintenance_window         = "Sun:17:00-Sun:17:30"
  # TODO: For production set multi_az to true
  multi_az = false
  auto_minor_version_upgrade = true
  # TODO: For production change apply_immediately to false
  apply_immediately          = true
  # TODO: For production change skip_final_snapshot to false
  skip_final_snapshot        = true
  vpc_security_group_ids     = ["${aws_security_group.postgresql.id}"]
}
