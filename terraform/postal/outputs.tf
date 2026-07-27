output "ipv4_address" {
  value = linode_instance.main.ip_address
}

output "ipv6_address" {
  value = cidrhost(linode_instance.main.ipv6, 0)
}
