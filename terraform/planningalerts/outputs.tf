output "certificate_production" {
  value = aws_acm_certificate.main
}

output "sitemaps_secret_access_key" {
  value     = aws_iam_access_key.sitemaps.secret
  sensitive = true
}

output "sitemaps_access_key_id" {
  value = aws_iam_access_key.sitemaps.id
}
