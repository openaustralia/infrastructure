output "certificate_production" {
  value = module.certificate.certificate
}

output "sitemaps_secret_access_key" {
  value     = aws_iam_access_key.sitemaps.secret
  sensitive = true
}

output "sitemaps_access_key_id" {
  value = aws_iam_access_key.sitemaps.id
}

output "activestorage_s3_secret_access_key" {
  value     = module.activestorage-s3.secret_access_key
  sensitive = true
}

output "activestorage_s3_access_key_id" {
  value = module.activestorage-s3.access_key_id
}
