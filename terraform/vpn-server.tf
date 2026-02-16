module "vpn_server" {
  source = "./vpn-server"

  webserver_security_group_id      = aws_security_group.webserver.id
  planningalerts_security_group_id = aws_security_group.planningalerts.id
}

output "vpn_server_ip" {
  description = "OpenVPN server public IP"
  value       = module.vpn_server.vpn_server_ip
}

output "vpn_server_private_ip" {
  description = "OpenVPN server private IP"
  value       = module.vpn_server.vpn_server_private_ip
}

output "vpn_users_group_name" {
  description = "IAM group name for VPN access"
  value       = module.vpn_server.vpn_users_group_name
}
