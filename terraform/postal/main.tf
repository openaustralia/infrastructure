terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4.0"
    }
    linode = {
      source  = "linode/linode"
      version = "~> 2.5.2"
    }
  }
}

resource "linode_instance" "main" {
  region = "ap-southeast"
  # Postal's documented minimum (4GB / 2 cores). Resizing to g6-standard-4
  # later is a quick reboot because resize_disk is false.
  type             = "g6-standard-2"
  label            = "postal"
  image            = "linode/ubuntu22.04"
  authorized_keys  = [var.authorized_key]
  booted           = true
  backups_enabled  = true
  watchdog_enabled = true
  resize_disk      = false
}

# Forward and reverse DNS must match (FCrDNS) or major mail receivers
# will junk or reject what we send
resource "linode_rdns" "ipv4" {
  address = linode_instance.main.ip_address
  rdns    = "postal.oaf.org.au"
}

resource "linode_rdns" "ipv6" {
  address = cidrhost(linode_instance.main.ipv6, 0)
  rdns    = "postal.oaf.org.au"
}

# Provider-level firewall, the Linode equivalent of the AWS security groups
# used elsewhere in this repo. 2525 is the legacy Cuttlefish submission port
# that clients keep using; an iptables rule on the host redirects it to 25.
resource "linode_firewall" "main" {
  label = "postal"

  inbound {
    label    = "ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "smtp"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "25"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "smtp-legacy-submission"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "2525"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [linode_instance.main.id]
}
