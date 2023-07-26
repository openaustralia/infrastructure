resource "linode_instance" "morph" {
  region           = "us-west"
  type             = "g6-standard-8"
  label            = "morph"
  group            = "morph"
  booted           = true
  backups_enabled  = false
  watchdog_enabled = true
  private_ip       = false
  resize_disk      = false
  # We can't set the image below because it would force replacement
  # image            = "linode/ubuntu16.04lts"
}
