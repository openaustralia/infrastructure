# Output cuttlefish server details
output "ipv4_address" {
  value       = linode_instance.main.ip_address
  description = "IPv4 address of the cuttlefish server"
}

output "ipv6_address" {
  value       = cidrhost(linode_instance.main.ipv6, 0)
  description = "IPv6 address of the cuttlefish server"
}
