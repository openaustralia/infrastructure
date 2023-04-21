output "public_ips" {
  value = aws_instance.main[*].public_ip
}

output "public_names" {
  value = cloudflare_record.main[*].name
}

output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}
