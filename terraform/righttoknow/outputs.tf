# Output staging server details for use with Ansible
output "staging_public_ip" {
  value       = aws_eip.staging.public_ip
  description = "Public IP address of the staging server"
}

output "staging_instance_id" {
  value       = aws_instance.staging.id
  description = "Instance ID of the staging server"
}

output "staging_dns" {
  value       = "staging.righttoknow.org.au"
  description = "Main DNS name for staging"
}
