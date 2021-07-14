resource "aws_instance" "planningalerts" {
  ami = data.aws_ami.ubuntu.id

  # A quick look at newrelic is showing PlanningAlerts on kedumba
  # using about 1.5GB. A medium instance gives us 4GB
  # We t2.medium we were running out of memory when the scraping and emailing
  # setup happens at 12pm. There was also a bug which was causing multiple
  # instances of this to run at the same time until the memory was exhausted
  # and the server crashed. So, upped the instance size just to be on the
  # safe size.
  # After a couple of days of seeing the memory behaviour around 12pm
  # with the new instance size we realised we could in fact move back down
  # to the smaller t2.medium.
  # After moving to sidekiq we seem to be needing some more memory.
  # So increased the instance type to t2.large.
  # TODO: It would be good to check if we can go smaller again
  instance_type = "t3.large"
  ebs_optimized = true
  key_name      = "test"
  tags = {
    Name = "planningalerts"
  }
  security_groups         = [
    aws_security_group.webserver.name,
    aws_security_group.planningalerts.name
  ]
  disable_api_termination = true
  iam_instance_profile    = aws_iam_instance_profile.logging.name
}

resource "aws_eip" "planningalerts" {
  instance = aws_instance.planningalerts.id
  tags = {
    Name = "planningalerts"
  }
}

resource "aws_elasticache_cluster" "planningalerts" {
  cluster_id           = "planningalerts"
  engine               = "redis"
  # Smallest t3 available gives 0.5 GiB memory
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.0.5"
  port                 = 6379

  # TODO: Change this to false for production use!
  apply_immediately    = true

  security_group_ids = [ aws_security_group.redis-planningalerts.id ]

  # We want Monday 4-5am Sydney time which is Sunday 5-6pm GMT.
  maintenance_window = "Sun:17:00-Sun:18:00"

  snapshot_retention_limit = 7

  # We want 2:30-3:30am Sydney time which is 3:30-4:30pm GMT
  snapshot_window = "15:30-16:30"
}
