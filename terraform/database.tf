resource "aws_iam_role" "rds-monitoring-role" {
  name = "rds-monitoring-role"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "monitoring.rds.amazonaws.com"
          }
          Sid = ""
        },
      ]
      Version = "2012-10-17"
    }
  )
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole",
  ]
}

# TODO: Do we want to explicitly set the available zone?
resource "aws_db_instance" "postgresql" {
  # Backup of righttoknow database was about 18GB. So, let's start with 50
  # like we did with the mysql database
  allocated_storage = 50

  # Using general purpose SSD
  storage_type   = "gp2"
  engine         = "postgres"
  engine_version = "15.17"

  instance_class          = "db.t4g.small"
  identifier              = "postgresql"
  username                = "root"
  password                = var.rds_admin_password
  publicly_accessible     = false
  backup_retention_period = 32

  # We want 3-3:30am Sydney time which is 4-4:30pm GMT
  backup_window = "16:00-16:30"

  # We want Monday 4-4:30am Sydney time which is Sunday 5-5:30pm GMT.
  maintenance_window         = "Sun:17:00-Sun:17:30"
  multi_az                   = true
  auto_minor_version_upgrade = true

  apply_immediately      = false
  skip_final_snapshot    = false
  vpc_security_group_ids = [aws_security_group.postgresql.id]
  deletion_protection    = true
}

# maindb MySQL 8.4 instance
resource "aws_db_instance" "maindb" {
  allocated_storage = 50

  # Using general purpose SSD
  storage_type   = "gp2"
  engine         = "mysql"
  engine_version = "8.4.6"

  # Required by AWS to perform a major version upgrade (8.0 -> 8.4) in place.
  # TODO: Remove this (or set back to false) once the upgrade has completed,
  # so an accidental engine_version bump in future can't trigger a surprise
  # major version upgrade.
  allow_major_version_upgrade = false

  instance_class      = "db.t3.small"
  identifier          = "maindb"
  username            = "admin"
  password            = var.rds_admin_password
  publicly_accessible = false

  # db.t3.small doesn't support performance_insights.
  performance_insights_enabled = false

  # Enable enhanced monitoring
  monitoring_role_arn = aws_iam_role.rds-monitoring-role.arn
  monitoring_interval = 60

  # Put the backup retention period to its maximum
  backup_retention_period = 32

  # We want 3-3:30am Sydney time which is 4-4:30pm GMT
  backup_window = "16:00-16:30"

  # We want Monday 4-4:30am Sydney time which is Sunday 5-5:30pm GMT.
  maintenance_window         = "sun:17:00-sun:17:30"
  multi_az                   = true
  auto_minor_version_upgrade = true
  apply_immediately          = false
  skip_final_snapshot        = true
  vpc_security_group_ids     = [aws_security_group.main_database.id]
  parameter_group_name       = "default.mysql8.4"
  deletion_protection        = false
  copy_tags_to_snapshot      = true
}

