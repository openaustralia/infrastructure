# DMS Migration Setup for MySQL 5.7 -> MySQL 8.0
# Continuous replication during application migration period

# DMS Subnet Group
resource "aws_dms_replication_subnet_group" "main" {
  replication_subnet_group_id = "dms-mysql-migration"
  replication_subnet_group_description = "DMS subnet group for MySQL 5.7 to 8.0 migration"

  subnet_ids = [
    "subnet-77797315", # ap-southeast-2a
    "subnet-55bd8921", # ap-southeast-2b
    "subnet-07ce9141", # ap-southeast-2c
  ]

  tags = {
    Name = "DMS MySQL Migration"
  }
}

# Security Group for DMS Replication Instance
resource "aws_security_group" "dms_replication" {
  name        = "dms-replication"
  description = "Security group for DMS replication instance"

  # Allow all outbound for DMS operations
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DMS Replication Instance"
  }
}

# Allow DMS to access main_database security group
resource "aws_security_group_rule" "main_database_from_dms" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.dms_replication.id
  security_group_id        = aws_security_group.main_database.id
  description              = "Allow DMS replication instance access"
}

# DMS Replication Instance
resource "aws_dms_replication_instance" "main" {
  replication_instance_id   = "mysql-migration"
  replication_instance_class = "dms.t3.medium"
  allocated_storage          = 100

  multi_az = false

  replication_subnet_group_id = aws_dms_replication_subnet_group.main.id
  vpc_security_group_ids      = [aws_security_group.dms_replication.id]

  publicly_accessible = false
  engine_version = "3.5.4"

  preferred_maintenance_window = "sun:18:00-sun:19:00"

  tags = {
    Name = "MySQL 5.7 to 8.0 Migration"
  }
}

# Source Endpoint - main-database (MySQL 5.7)
resource "aws_dms_endpoint" "source" {
  endpoint_id   = "source-main-database"
  endpoint_type = "source"
  engine_name   = "mysql"

  server_name = aws_db_instance.main.address
  port        = 3306
  username    = "admin"
  password    = var.rds_admin_password

  ssl_mode = "none"

  tags = {
    Name = "Source main-database MySQL 5.7"
  }
}

# Target Endpoint - maindb (MySQL 8.0)
resource "aws_dms_endpoint" "target" {
  endpoint_id   = "target-maindb"
  endpoint_type = "target"
  engine_name   = "mysql"

  server_name = aws_db_instance.maindb.address
  port        = 3306
  username    = "admin"
  password    = var.rds_admin_password

  ssl_mode = "none"

  tags = {
    Name = "Target maindb MySQL 8.0"
  }
}

# DMS Replication Task
# CDC mode with start position set to snapshot time
resource "aws_dms_replication_task" "mysql_migration" {
  replication_task_id       = "mysql-57-to-80-migration"
  replication_instance_arn  = aws_dms_replication_instance.main.replication_instance_arn
  source_endpoint_arn       = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.target.endpoint_arn

  migration_type = "cdc"
  cdc_start_time = "2025-11-18T16:07:39"

  table_mappings = jsonencode({
    rules = [
      {
        rule-type = "selection"
        rule-id   = "1"
        rule-name = "replicate-all-tables"
        object-locator = {
          schema-name = "%"
          table-name  = "%"
        }
        rule-action = "include"
      }
    ]
  })

  replication_task_settings = jsonencode({
    TargetMetadata = {
      SupportLobs = true
      LobMaxSize  = 32
    }
    FullLoadSettings = {
      TargetTablePrepMode = "DO_NOTHING"
    }
    Logging = {
      EnableLogging = true
      LogComponents = [
        {
          Id       = "TRANSFORMATION"
          Severity = "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id       = "SOURCE_CAPTURE"
          Severity = "LOGGER_SEVERITY_INFO"
        },
        {
          Id       = "TARGET_APPLY"
          Severity = "LOGGER_SEVERITY_INFO"
        }
      ]
    }
    ChangeProcessingDdlHandlingPolicy = {
      HandleSourceTableDropped   = true
      HandleSourceTableTruncated = true
      HandleSourceTableAltered   = true
    }
    ChangeProcessingTuning = {
      BatchApplyPreserveTransaction  = true
      BatchApplyTimeoutMin           = 1
      BatchApplyTimeoutMax           = 30
      MinTransactionSize             = 1000
      CommitTimeout                  = 1
      MemoryLimitTotal               = 1024
      MemoryKeepTime                 = 60
      BatchApplyMemoryLimit          = 500
    }
  })

  # Don't auto-start since we manually started it
  start_replication_task = false

  tags = {
    Name = "MySQL 5.7 to 8.0 CDC Replication"
  }

  depends_on = [
    aws_dms_replication_instance.main,
    aws_dms_endpoint.source,
    aws_dms_endpoint.target
  ]
}
