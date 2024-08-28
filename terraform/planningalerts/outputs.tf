output "certificate_production" {
  value = aws_acm_certificate.main
}

# TODO: Rename
output "planningalerts_sitemaps_production_secret_access_key" {
  value     = aws_iam_access_key.sitemaps.secret
  sensitive = true
}

output "planningalerts_sitemaps_production_access_key_id" {
  value = aws_iam_access_key.sitemaps.id
}
