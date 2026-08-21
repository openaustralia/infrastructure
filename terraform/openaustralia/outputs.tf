# Output main server details
output "production_public_ip" {
  value       = aws_eip.production.public_ip
  description = "Public IP address of the production openaustralia server"
}
