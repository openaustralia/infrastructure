output "vpn_server_ip" {
  description = "OpenVPN server public IP"
  value       = aws_eip.openvpn.public_ip
}

output "vpn_server_private_ip" {
  description = "OpenVPN server private IP"
  value       = aws_instance.openvpn.private_ip
}

output "vpn_users_group_name" {
  description = "IAM group name for VPN access"
  value       = aws_iam_group.vpn_users.name
}
