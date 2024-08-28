output "certificate_production" {
  value = aws_acm_certificate.main
}

# TODO: These need to be output by the top level!

# These values are needed by ansible for planningalerts
# They should be encrypted and put in group_vars/planningalerts.yml
# Take the output of this command:
# terraform output planningalerts_sitemaps_production_access_key_id
# cd ..; ansible-vault encrypt_string --name aws_access_key_id "value from above" --encrypt-vault-id default
# AND
# terraform output planningalerts_sitemaps_production_secret_access_key
# cd ..; ansible-vault encrypt_string --name aws_secret_access_key "value from above" --encrypt-vault-id default

output "planningalerts_sitemaps_production_secret_access_key" {
  value     = aws_iam_access_key.sitemaps.secret
  sensitive = true
}

output "planningalerts_sitemaps_production_access_key_id" {
  value = aws_iam_access_key.sitemaps.id
}
