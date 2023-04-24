resource "aws_db_instance" "main" {
  # kedumba has a 150GB disk so let's start with 50GB of database
  allocated_storage = 50

  # Using general purpose SSD
  storage_type   = "gp2"
  engine         = "mysql"
  engine_version = "5.7.38"

  instance_class      = "db.t3.small"
  identifier          = "main-database"
  username            = "admin"
  password            = var.rds_admin_password
  publicly_accessible = false

  # TODO: Do we actually need this extra monitoring always on?

  # db.t3.small doesn't support performance_insights.
  # So if we want to use it we need to upgrade the database to db.t3.medium
  performance_insights_enabled = false

  # Enable enhanced monitoring
  monitoring_role_arn = aws_iam_role.rds-monitoring-role.arn
  monitoring_interval = 60

  # Put the backup retention period to its maximum until we figure out what's a
  # good overall backup scheme
  # TODO: Set this to its final value
  backup_retention_period = 35

  # We want 3-3:30am Sydney time which is 4-4:30pm GMT
  backup_window = "16:00-16:30"

  # We want Monday 4-4:30am Sydney time which is Sunday 5-5:30pm GMT.
  maintenance_window         = "Sun:17:00-Sun:17:30"
  multi_az                   = true
  auto_minor_version_upgrade = true
  apply_immediately          = false
  skip_final_snapshot        = false
  vpc_security_group_ids     = [aws_security_group.main_database.id]
  # The parameter group name below was automatically created during an upgrade to mysql 5.7
  # The commented out group name was the one we were using with mysql 5.6
  # TODO: Go through parameter group and see if anything is different than the 5.7 default and if so make a custom one for us
  # parameter_group_name       = aws_db_parameter_group.mysql_default.name
  parameter_group_name = "default.mysql5.7-db-3zfhxnxjf2w5aymy2dl3hbsk3m-upgrade"
  deletion_protection  = true
}

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
  engine_version = "15.2"

  # Let's start in production with db.t2.medium. We should watch the cpu credits
  # Dropping down to db.t2.small because we're under-using
  # Switching to t3.small because it's more recent, same price, and double the cpu
  instance_class          = "db.t3.small"
  identifier              = "postgresql"
  username                = "root"
  password                = var.rds_admin_password
  publicly_accessible     = false
  backup_retention_period = 35

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

resource "aws_db_parameter_group" "mysql_default" {
  name        = "mysql-default"
  description = "Our default for mysql 5.6"
  family      = "mysql5.6"

  # Allow triggers on mysql
  parameter {
    name         = "log_bin_trust_function_creators"
    value        = 1
    apply_method = "pending-reboot"
  }

  # To use utf8mb4 with mysql 5.6 we need to enable innodb_large_prefix. See
  # https://edgeguides.rubyonrails.org/configuring.html#configuring-a-mysql-or-mariadb-database
  parameter {
    name  = "innodb_large_prefix"
    value = 1
  }

  # Setting the innodb_large_prefix (above) only works when using the newer
  # row formats DYNAMIC or COMPRESSED. These row formats are only supported
  # in the newer Barracuda file format
  parameter {
    name  = "innodb_file_format"
    value = "Barracuda"
  }
  # See https://dev.mysql.com/doc/refman/5.7/en/charset-unicode-conversion.html
  # This is actually already set by default on RDS. So just confuses things
  # to set it explicitly
  # parameter {
  #   name = "innodb_file_per_table"
  #   value = 1
  # }
}
