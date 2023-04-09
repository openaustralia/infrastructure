output "secret_access_key" {
  value = aws_iam_access_key.main.secret
  sensitive = true
}

output "access_key_id" {
  value = aws_iam_access_key.main.id
}
