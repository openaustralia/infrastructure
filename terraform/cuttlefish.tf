resource "linode_instance" "cuttlefish" {
  region           = "us-west"
  type             = "g6-standard-4"
  label            = "cuttlefish"
  booted           = true
  backups_enabled  = true
  watchdog_enabled = true
  private_ip       = true
  resize_disk      = false
  # We want to set the "image" here but I don't think we can because
  # this was originally created with Ubuntu 14.04
}

# Temporary instance to run pgcopydb (https://pgcopydb.readthedocs.io/en/latest/index.html)
# for migrating postgres database from local one to managed one run by linode
resource "linode_instance" "cuttlefish_db_migration" {
  region = "us-west"
  type   = "g6-standard-4"
  label  = "cuttlefish_db_migration"
  booted = true
  image  = "linode/ubuntu23.04"
}

resource "linode_rdns" "cuttlefish_ipv4" {
  address = linode_instance.cuttlefish.ip_address
  rdns    = "cuttlefish.oaf.org.au"
}

resource "linode_rdns" "cuttlefish_ipv6" {
  address = cidrhost(linode_instance.cuttlefish.ipv6, 0)
  rdns    = "cuttlefish.oaf.org.au"
}

resource "linode_database_postgresql" "cuttlefish" {
  # This is the current latest available version which is different than
  # what is currently used in production on cuttlefish
  engine_id      = "postgresql/14.6"
  label          = "cuttlefish"
  region         = "us-west"
  type           = "g6-standard-2"
  ssl_connection = true
  # We're sticking with a single node to save money
  cluster_size = 1
  # Using same maintenance window as used in planningalerts database
  updates {
    day_of_week = "sunday"
    duration    = 1
    frequency   = "weekly"
    hour_of_day = 17
  }
  # Only allow the database to be contacted directly from the cuttlefish instance.
  # For some reason the ip address needs to be the public ip address even when
  # contacting the database via the private network
  # Also temporarily allow migration instance access as well
  allow_list = [linode_instance.cuttlefish.ip_address, linode_instance.cuttlefish_db_migration.ip_address]
}

# These values are needed by ansible for cuttlefish
# They need to be added semi-manually in the following way
# `terraform output cuttlefish_db_host`
# `terraform output cuttlefish_db_root_username`
# `terraform output cuttlefish_db_root_password`
# `cd <cuttlefish repo>`
# Edit value db_host in provisioning/roles/cuttlefish-app/vars/main.yml to be value of "terraform output cuttlefish_db_host" above
# Edit value db_root_username in provisioning/roles/cuttlefish-app/vars/main.yml to be value of "terraform output cuttlefish_db_root_username" above
# `ansible-vault encrypt_string --name db_root_password <value from terraform output cuttlefish_db_root_password above> --encrypt-vault-id default`
# Edit value db_root_password in provisioning/roles/cuttlefish-app/vars/main.yml to be output of command above

output "cuttlefish_db_host" {
  value = linode_database_postgresql.cuttlefish.host_secondary
}

output "cuttlefish_db_root_username" {
  value     = linode_database_postgresql.cuttlefish.root_username
  sensitive = true
}

output "cuttlefish_db_root_password" {
  value     = linode_database_postgresql.cuttlefish.root_password
  sensitive = true
}
