terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.13.2"
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
  backups_enabled  = false
  watchdog_enabled = true
  private_ip       = false
  resize_disk      = false
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

moved {
  from = linode_instance.morph
  to   = linode_instance.main
}

# I don't really understand why we set up reverse DNS when we created the instance manually
resource "linode_rdns" "main" {
  address = linode_instance.main.ip_address
  rdns    = "morph.io"
}

moved {
  from = linode_rdns.morph_ipv4
  to   = linode_rdns.main
}
