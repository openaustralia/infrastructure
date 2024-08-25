terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.13.2"
    }
    linode = {
      source  = "linode/linode"
      version = "~> 2.5.2"
    }
  }
}

resource "linode_instance" "main" {
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

resource "linode_rdns" "ipv4" {
  address = linode_instance.main.ip_address
  rdns    = "cuttlefish.oaf.org.au"
}

resource "linode_rdns" "ipv6" {
  address = cidrhost(linode_instance.main.ipv6, 0)
  rdns    = "cuttlefish.oaf.org.au"
}
