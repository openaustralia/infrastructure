module "cuttlefish" {
  source             = "./cuttlefish"
  oaf_org_au_zone_id = var.oaf_org_au_zone_id
  cuttlefish_ipv4    = var.cuttlefish_ipv4
  cuttlefish_ipv6    = var.cuttlefish_ipv6
}

module "electionleaflets" {
  source           = "./electionleaflets"
  security_group   = aws_security_group.webserver
  instance_profile = aws_iam_instance_profile.logging
  ami              = var.ubuntu_16_ami
}

module "planningalerts" {
  source           = "./planningalerts"
  instance_profile = aws_iam_instance_profile.logging
  # Not sure if it's better to pass this in or whether this module should just make its own version of it
  security_group_incoming_email = aws_security_group.incoming_email
  deployer_key                  = aws_key_pair.deployer
  load_balancer                 = aws_lb.main
  security_group_postgresql     = aws_security_group.postgresql
  rds_monitoring_role           = aws_iam_role.rds-monitoring-role
  rds_admin_password            = var.rds_admin_password
  listener_http                 = aws_lb_listener.main-http
  listener_https                = aws_lb_listener.main-https
  security_group_behind_lb      = aws_security_group.planningalerts
  vpc                           = aws_default_vpc.default
}

moved {
  from = cloudflare_record.pa_incoming_email
  to   = module.planningalerts.cloudflare_record.pa_incoming_email
}

moved {
  from = cloudflare_record.pa_root
  to   = module.planningalerts.cloudflare_record.pa_root
}

moved {
  from = cloudflare_record.pa_www
  to   = module.planningalerts.cloudflare_record.pa_www
}

moved {
  from = cloudflare_record.pa_api
  to   = module.planningalerts.cloudflare_record.pa_api
}

moved {
  from = cloudflare_record.pa_email
  to   = module.planningalerts.cloudflare_record.pa_email
}

moved {
  from = cloudflare_record.pa_email2
  to   = module.planningalerts.cloudflare_record.pa_email2
}

moved {
  from = cloudflare_record.pa_donate
  to   = module.planningalerts.cloudflare_record.pa_donate
}

moved {
  from = cloudflare_record.pa_mx1
  to   = module.planningalerts.cloudflare_record.pa_mx1
}

moved {
  from = cloudflare_record.pa_mx2
  to   = module.planningalerts.cloudflare_record.pa_mx2
}

moved {
  from = cloudflare_record.pa_mx3
  to   = module.planningalerts.cloudflare_record.pa_mx3
}

moved {
  from = cloudflare_record.pa_mx4
  to   = module.planningalerts.cloudflare_record.pa_mx4
}

moved {
  from = cloudflare_record.pa_mx5
  to   = module.planningalerts.cloudflare_record.pa_mx5
}

moved {
  from = cloudflare_record.pa_spf
  to   = module.planningalerts.cloudflare_record.pa_spf
}

moved {
  from = cloudflare_record.pa_google_site_verification
  to   = module.planningalerts.cloudflare_record.pa_google_site_verification
}

moved {
  from = cloudflare_record.pa_facebook_domain_verification
  to   = module.planningalerts.cloudflare_record.pa_facebook_domain_verification
}

moved {
  from = cloudflare_record.pa_domainkey
  to   = module.planningalerts.cloudflare_record.pa_domainkey
}

moved {
  from = cloudflare_record.pa_domainkey2
  to   = module.planningalerts.cloudflare_record.pa_domainkey2
}

moved {
  from = cloudflare_record.pa_domainkey_google
  to   = module.planningalerts.cloudflare_record.pa_domainkey_google
}

moved {
  from = cloudflare_record.cert-validation-production
  to   = module.planningalerts.cloudflare_record.cert-validation-production
}

moved {
  from = cloudflare_record.pa_dmarc
  to   = module.planningalerts.cloudflare_record.pa_dmarc
}

moved {
  from = aws_db_parameter_group.md5
  to   = module.planningalerts.aws_db_parameter_group.md5
}

moved {
  from = aws_db_instance.planningalerts
  to   = module.planningalerts.aws_db_instance.planningalerts
}

moved {
  from = aws_elasticache_cluster.planningalerts
  to   = module.planningalerts.aws_elasticache_cluster.planningalerts
}

moved {
  from = aws_elasticache_parameter_group.sidekiq
  to   = module.planningalerts.aws_elasticache_parameter_group.sidekiq
}

moved {
  from = aws_acm_certificate.planningalerts-production
  to   = module.planningalerts.aws_acm_certificate.planningalerts-production
}

moved {
  from = aws_acm_certificate_validation.planningalerts-production
  to   = module.planningalerts.aws_acm_certificate_validation.planningalerts-production
}

moved {
  from = aws_lb_listener_rule.planningalerts-redirect-http-to-https
  to   = module.planningalerts.aws_lb_listener_rule.planningalerts-redirect-http-to-https
}

moved {
  from = aws_lb_listener_rule.redirect-https-to-planningalerts-canonical
  to   = module.planningalerts.aws_lb_listener_rule.redirect-https-to-planningalerts-canonical
}

moved {
  from = aws_lb_listener_rule.main-https-redirect-sitemaps-production
  to   = module.planningalerts.aws_lb_listener_rule.main-https-redirect-sitemaps-production
}

moved {
  from = aws_lb_listener_rule.main-https-forward-planningalerts
  to   = module.planningalerts.aws_lb_listener_rule.main-https-forward-planningalerts
}

moved {
  from = google_apikeys_key.google_maps_email_key
  to   = module.planningalerts.google_apikeys_key.google_maps_email_key
}

moved {
  from = google_apikeys_key.google_maps_key
  to   = module.planningalerts.google_apikeys_key.google_maps_key
}

moved {
  from = google_apikeys_key.google_maps_server_key
  to   = module.planningalerts.google_apikeys_key.google_maps_server_key
}

moved {
  from = aws_s3_bucket.planningalerts_sitemaps_production
  to   = module.planningalerts.aws_s3_bucket.planningalerts_sitemaps_production
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.planningalerts_sitemaps_production
  to   = module.planningalerts.aws_s3_bucket_server_side_encryption_configuration.planningalerts_sitemaps_production
}

moved {
  from = aws_iam_user.planningalerts_sitemaps_production
  to   = module.planningalerts.aws_iam_user.planningalerts_sitemaps_production
}

moved {
  from = aws_iam_access_key.planningalerts_sitemaps_production
  to   = module.planningalerts.aws_iam_access_key.planningalerts_sitemaps_production
}

moved {
  from = aws_iam_user_policy.upload_to_planningalerts_sitemaps
  to   = module.planningalerts.aws_iam_user_policy.upload_to_planningalerts_sitemaps
}

moved {
  from = aws_security_group.planningalerts_memcached_server
  to   = module.planningalerts.aws_security_group.planningalerts_memcached_server
}

moved {
  from = aws_security_group.redis-planningalerts
  to   = module.planningalerts.aws_security_group.redis-planningalerts
}

moved {
  from = module.planningalerts-activestorage-s3-production.aws_iam_access_key.main
  to   = module.planningalerts.module.planningalerts-activestorage-s3-production.aws_iam_access_key.main
}

moved {
  from = module.planningalerts-activestorage-s3-production.aws_iam_user.main
  to   = module.planningalerts.module.planningalerts-activestorage-s3-production.aws_iam_user.main
}

moved {
  from = module.planningalerts-activestorage-s3-production.aws_iam_user_policy.main
  to   = module.planningalerts.module.planningalerts-activestorage-s3-production.aws_iam_user_policy.main
}

moved {
  from = module.planningalerts-activestorage-s3-production.aws_s3_bucket.main
  to   = module.planningalerts.module.planningalerts-activestorage-s3-production.aws_s3_bucket.main
}

moved {
  from = module.planningalerts-activestorage-s3-production.aws_s3_bucket_cors_configuration.main
  to   = module.planningalerts.module.planningalerts-activestorage-s3-production.aws_s3_bucket_cors_configuration.main
}

moved {
  from = module.planningalerts-activestorage-s3-production.aws_s3_bucket_public_access_block.main
  to   = module.planningalerts.module.planningalerts-activestorage-s3-production.aws_s3_bucket_public_access_block.main
}

moved {
  from = module.planningalerts-activestorage-s3-production.aws_s3_bucket_server_side_encryption_configuration.main
  to   = module.planningalerts.module.planningalerts-activestorage-s3-production.aws_s3_bucket_server_side_encryption_configuration.main
}

moved {
  from = module.planningalerts-env-blue.aws_lb_target_group.main
  to   = module.planningalerts.module.planningalerts-env-blue.aws_lb_target_group.main
}

moved {
  from = module.planningalerts-env-blue.aws_lb_target_group_attachment.main
  to   = module.planningalerts.module.planningalerts-env-blue.aws_lb_target_group_attachment.main
}

moved {
  from = module.planningalerts-env-blue.cloudflare_record.main
  to   = module.planningalerts.module.planningalerts-env-blue.cloudflare_record.main
}

moved {
  from = module.planningalerts-env-green.aws_lb_target_group.main
  to   = module.planningalerts.module.planningalerts-env-green.aws_lb_target_group.main
}
moved {
  from = module.planningalerts-env-blue.aws_instance.main
  to   = module.planningalerts.module.planningalerts-env-blue.aws_instance.main
}
