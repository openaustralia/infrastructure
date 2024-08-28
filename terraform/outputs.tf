# These values are needed by ansible for planningalerts
# They should be encrypted and put in group_vars/planningalerts.yml
# Take the output of this command:
# terraform output planningalerts_sitemaps_access_key_id
# cd ..; ansible-vault encrypt_string --name aws_access_key_id "value from above" --encrypt-vault-id default
# AND
# terraform output planningalerts_sitemaps_secret_access_key
# cd ..; ansible-vault encrypt_string --name aws_secret_access_key "value from above" --encrypt-vault-id default

output "planningalerts_sitemaps_secret_access_key" {
  value     = module.planningalerts.sitemaps_secret_access_key
  sensitive = true
}

output "planningalerts_sitemaps_access_key_id" {
  value = module.planningalerts.sitemaps_access_key_id
}

output "planningalerts_activestorage_s3_secret_access_key" {
  value     = module.planningalerts.activestorage_s3_secret_access_key
  sensitive = true
}

output "planningalerts_activestorage_s3_access_key_id" {
  value = module.planningalerts.activestorage_s3_access_key_id
}
