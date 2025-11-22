terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4.0"
    }
    linode = {
      source = "linode/linode"
    }
  }
}

resource "linode_instance" "main" {
  region           = "us-west"
  type             = "g6-standard-8"
  label            = "morph"
  group            = "morph"
  booted           = true
  backups_enabled  = true
  watchdog_enabled = true
  private_ip       = false
  # We can't set the image below because it would force replacement
  # image            = "linode/ubuntu16.04lts"

  # Disable alerts on things that were proving to be too noisy
  alerts {
    cpu         = 0
    io          = 0
    network_in  = 0
    network_out = 0
  }
}

# I don't really understand why we set up reverse DNS when we created the instance manually
resource "linode_rdns" "main" {
  address = linode_instance.main.ip_address
  rdns    = "morph.io"
}
