resource "aws_elasticsearch_domain" "main" {
  domain_name           = "main"
  # 6.4 is the current latest on AWS
  elasticsearch_version = "6.4"

  # TODO: Need to think through what a sensible instance type is here
  cluster_config {
    instance_type = "t2.small.elasticsearch"
    # These settings are only for testing/development. For production we'll
    # want to change these settings
    instance_count = 1
    dedicated_master_enabled = false
  }

  ebs_options {
    ebs_enabled = true
    # 10GB is the minimum storage that we can get started with
    # TODO: Figure out what we actually need
    volume_size = 10
  }

  # 14:00 in UTC is 1am Sydney time - things should be pretty quiet then
  snapshot_options {
    automated_snapshot_start_hour = 14
  }
}
