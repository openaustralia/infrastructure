output "public_ips" {
  value = aws_instance.main[*].public_ip
}

output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}
