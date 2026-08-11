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
  region           = "ap-southeast"
  type             = "g6-standard-2"
  label            = "postal"
  image            = "linode/ubuntu24.04"
  authorized_keys  = var.authorized_keys
  booted           = true
  backups_enabled  = true
  watchdog_enabled = true
}

# Reverse DNS must match the SMTP HELO hostname for mail deliverability
resource "linode_rdns" "ipv4" {
  address = linode_instance.main.ip_address
  rdns    = "postal.oaf.org.au"
}

resource "linode_rdns" "ipv6" {
  address = cidrhost(linode_instance.main.ipv6, 0)
  rdns    = "postal.oaf.org.au"
}

resource "linode_firewall" "main" {
  label           = "postal"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  inbound {
    label    = "allow-ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-smtp"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "25"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  linodes = [linode_instance.main.id]
}
