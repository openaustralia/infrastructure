output "instance_ids" {
  value = aws_instance.main[*].id
}

output "public_ips" {
  value = aws_instance.main[*].public_ip
}
