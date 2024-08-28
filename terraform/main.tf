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
  availability_zones            = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  instance_count                = 2
  # blue environment setup
  blue_enabled  = true
  blue_weight   = 1
  blue_ami_name = "planningalerts-ruby-3.3-v1"
  # green environment setup
  green_enabled  = false
  green_weight   = 0
  green_ami_name = "planningalerts-puma-ubuntu-22.04-v4"
}

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

module "theyvoteforyou" {
  source           = "./theyvoteforyou"
  ami              = var.ubuntu_20_ami
  deployer_key     = aws_key_pair.deployer
  security_group   = aws_security_group.webserver
  instance_profile = aws_iam_instance_profile.logging
}

moved {
  from = cloudflare_record.root
  to   = module.theyvoteforyou.cloudflare_record.root
}

moved {
  from = cloudflare_record.www
  to   = module.theyvoteforyou.cloudflare_record.www
}

moved {
  from = cloudflare_record.test
  to   = module.theyvoteforyou.cloudflare_record.test
}

moved {
  from = cloudflare_record.www_test
  to   = module.theyvoteforyou.cloudflare_record.www_test
}

moved {
  from = cloudflare_record.email
  to   = module.theyvoteforyou.cloudflare_record.email
}

moved {
  from = cloudflare_record.email2
  to   = module.theyvoteforyou.cloudflare_record.email2
}

moved {
  from = cloudflare_record.mx1
  to   = module.theyvoteforyou.cloudflare_record.mx1
}

moved {
  from = cloudflare_record.mx2
  to   = module.theyvoteforyou.cloudflare_record.mx2
}

moved {
  from = cloudflare_record.mx3
  to   = module.theyvoteforyou.cloudflare_record.mx3
}

moved {
  from = cloudflare_record.mx4
  to   = module.theyvoteforyou.cloudflare_record.mx4
}

moved {
  from = cloudflare_record.mx5
  to   = module.theyvoteforyou.cloudflare_record.mx5
}

moved {
  from = cloudflare_record.spf
  to   = module.theyvoteforyou.cloudflare_record.spf
}

moved {
  from = cloudflare_record.cuttlefish
  to   = module.theyvoteforyou.cloudflare_record.cuttlefish
}

moved {
  from = cloudflare_record.cuttlefish2
  to   = module.theyvoteforyou.cloudflare_record.cuttlefish2
}

moved {
  from = cloudflare_record.google_site_verification
  to   = module.theyvoteforyou.cloudflare_record.google_site_verification
}

moved {
  from = cloudflare_record.facebook_domain_verification
  to   = module.theyvoteforyou.cloudflare_record.facebook_domain_verification
}

moved {
  from = cloudflare_record.tvfy_domainkey_google
  to   = module.theyvoteforyou.cloudflare_record.tvfy_domainkey_google
}

moved {
  from = cloudflare_record.tvfy_dmarc
  to   = module.theyvoteforyou.cloudflare_record.tvfy_dmarc
}

moved {
  from = cloudflare_record.alt1_root
  to   = module.theyvoteforyou.cloudflare_record.alt1_root
}

moved {
  from = cloudflare_record.alt1_www
  to   = module.theyvoteforyou.cloudflare_record.alt1_www
}

moved {
  from = cloudflare_record.tvfy_alt1_dmarc
  to   = module.theyvoteforyou.cloudflare_record.tvfy_alt1_dmarc
}

moved {
  from = cloudflare_record.alt2_root
  to   = module.theyvoteforyou.cloudflare_record.alt2_root
}

moved {
  from = cloudflare_record.alt2_www
  to   = module.theyvoteforyou.cloudflare_record.alt2_www
}

moved {
  from = cloudflare_record.tvfy_alt2_dmarc
  to   = module.theyvoteforyou.cloudflare_record.tvfy_alt2_dmarc
}


moved {
  from = aws_instance.theyvoteforyou
  to   = module.theyvoteforyou.aws_instance.theyvoteforyou
}

moved {
  from = aws_eip.theyvoteforyou
  to   = module.theyvoteforyou.aws_eip.theyvoteforyou
}

moved {
  from = aws_ebs_volume.theyvoteforyou_data
  to   = module.theyvoteforyou.aws_ebs_volume.theyvoteforyou_data
}

moved {
  from = aws_volume_attachment.theyvoteforyou_data
  to   = module.theyvoteforyou.aws_volume_attachment.theyvoteforyou_data
}
