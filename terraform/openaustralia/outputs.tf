# Output main server details
output "main_public_ip" {
  value       = aws_eip.main.public_ip
  description = "Public IP address of the main openaustralia server"
}

output "production_public_ip" {
  value       = aws_eip.production.public_ip
  description = "Public IP address of the production openaustralia server"
}
