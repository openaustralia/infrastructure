# Postgres and redis (elasticache) configuration are here

# TODO: Delete this parameter group as soon as it's not used by the planningalerts db anymore
resource "aws_db_parameter_group" "md5" {
  description = "Allow access via md5 for pgloader"
  family      = "postgres15"
  name        = "md5"

  # With this setting new passwords use the old md5 password hashing. We need
  # this set before passwords are created for the planningalerts postgresl roles
  # so that pgloader can access postgresql.
  # TODO: One migration is done we should switch this back to the default
  # This will probably involve just removing this parameter group and switching
  # back to the default
  parameter {
    apply_method = "immediate"
    name         = "password_encryption"
    value        = "md5"
  }

  # We're also disabling the forcing of ssl so that pgloader can do its business
  parameter {
    apply_method = "immediate"
    name         = "rds.force_ssl"
    value        = 0
  }
}

resource "aws_db_instance" "main" {
  # TODO: Less space should be needed in production
  # TODO: Enable storage autoscaling
  # TODO: Set maximum storage threshold to 200GB? 
  allocated_storage = 50

  # Using general purpose SSD
  storage_type   = "gp3"
  engine         = "postgres"
  engine_version = "15.7"
  # We can't specify iops when creating the database
  # This is the baseline for storage less than 400 GB
  iops = 3000

  # Even though db.m7g.large are available we can't use them
  # yet because we can't buy reserved instances for them. Sigh.
  instance_class          = "db.m6g.large"
  identifier              = "planningalerts"
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

  apply_immediately   = false
  skip_final_snapshot = false

  # TODO: Limit traffic to only from planningalerts servers for production?
  vpc_security_group_ids = [var.security_group_postgresql.id]
  parameter_group_name   = "default.postgres15"

  # Enable performance insights
  performance_insights_enabled = true

  # Enable enhanced monitoring
  monitoring_role_arn = var.rds_monitoring_role.arn
  monitoring_interval = 60

  deletion_protection = true
}

resource "aws_elasticache_cluster" "main" {
  cluster_id = "planningalerts"
  engine     = "redis"
  # Smallest t3 available gives 0.5 GiB memory
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.sidekiq.name
  engine_version       = "6.2"
  port                 = 6379

  apply_immediately = false

  security_group_ids = [aws_security_group.redis.id]

  # We want Monday 4-5am Sydney time which is Sunday 5-6pm GMT.
  maintenance_window = "Sun:17:00-Sun:18:00"

  snapshot_retention_limit = 7

  # We want 2:30-3:30am Sydney time which is 3:30-4:30pm GMT
  snapshot_window = "15:30-16:30"
}

# Redis setup required for sidekiq.
# See https://github.com/mperham/sidekiq/wiki/Using-Redis
resource "aws_elasticache_parameter_group" "sidekiq" {
  name   = "sidekiq"
  family = "redis6.x"

  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }
}

