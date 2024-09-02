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

module "theyvoteforyou" {
  source           = "./theyvoteforyou"
  ami              = var.ubuntu_20_ami
  deployer_key     = aws_key_pair.deployer
  security_group   = aws_security_group.webserver
  instance_profile = aws_iam_instance_profile.logging
}

module "righttoknow" {
  source                        = "./righttoknow"
  security_group_webserver      = aws_security_group.webserver
  security_group_incoming_email = aws_security_group.incoming_email
  instance_profile              = aws_iam_instance_profile.logging
  # This has been upgraded in place to Ubuntu 18.04
  ami = var.ubuntu_16_ami
}

module "morph" {
  source = "./morph"
  ipv4   = var.morph_ipv4
}

module "oaf" {
  source                   = "./oaf"
  oaf_org_au_zone_id       = var.oaf_org_au_zone_id
  security_group_webserver = aws_security_group.webserver
  instance_profile         = aws_iam_instance_profile.logging
  # This has been upgraded in place to Ubuntu 18.04
  ami = var.ubuntu_16_ami
}


moved {
  from = cloudflare_record.oaf_root
  to   = module.oaf.cloudflare_record.oaf_root
}

moved {
  from = cloudflare_record.oaf_test
  to   = module.oaf.cloudflare_record.oaf_test
}

moved {
  from = cloudflare_record.oaf_www
  to   = module.oaf.cloudflare_record.oaf_www
}

moved {
  from = cloudflare_record.oaf_email
  to   = module.oaf.cloudflare_record.oaf_email
}

moved {
  from = cloudflare_record.social
  to   = module.oaf.cloudflare_record.social
}

moved {
  from = cloudflare_record.oaf_mx1
  to   = module.oaf.cloudflare_record.oaf_mx1
}

moved {
  from = cloudflare_record.oaf_mx2
  to   = module.oaf.cloudflare_record.oaf_mx2
}

moved {
  from = cloudflare_record.oaf_mx3
  to   = module.oaf.cloudflare_record.oaf_mx3
}

moved {
  from = cloudflare_record.oaf_mx4
  to   = module.oaf.cloudflare_record.oaf_mx4
}

moved {
  from = cloudflare_record.oaf_mx5
  to   = module.oaf.cloudflare_record.oaf_mx5
}

moved {
  from = cloudflare_record.oaf_spf
  to   = module.oaf.cloudflare_record.oaf_spf
}

moved {
  from = cloudflare_record.oaf_google_site_verification
  to   = module.oaf.cloudflare_record.oaf_google_site_verification
}

moved {
  from = cloudflare_record.oaf_facebook_domain_verification
  to   = module.oaf.cloudflare_record.oaf_facebook_domain_verification
}

moved {
  from = cloudflare_record.oaf_domainkey_campaign_monitor
  to   = module.oaf.cloudflare_record.oaf_domainkey_campaign_monitor
}

moved {
  from = cloudflare_record.oaf_github_challenge
  to   = module.oaf.cloudflare_record.oaf_github_challenge
}

moved {
  from = cloudflare_record.oaf_github_challenge2
  to   = module.oaf.cloudflare_record.oaf_github_challenge2
}

moved {
  from = cloudflare_record.oaf_domainkey_google
  to   = module.oaf.cloudflare_record.oaf_domainkey_google
}

moved {
  from = cloudflare_record.oaf_domainkey_cuttlefish
  to   = module.oaf.cloudflare_record.oaf_domainkey_cuttlefish
}

moved {
  from = cloudflare_record.oaf_dmarc
  to   = module.oaf.cloudflare_record.oaf_dmarc
}

moved {
  from = cloudflare_record.oaf_alt_root
  to   = module.oaf.cloudflare_record.oaf_alt_root
}

moved {
  from = cloudflare_record.oaf_alt_www
  to   = module.oaf.cloudflare_record.oaf_alt_www
}

moved {
  from = cloudflare_record.oaf_alt_test
  to   = module.oaf.cloudflare_record.oaf_alt_test
}

moved {
  from = cloudflare_record.oaf_alt_mx1
  to   = module.oaf.cloudflare_record.oaf_alt_mx1
}

moved {
  from = cloudflare_record.oaf_alt_mx2
  to   = module.oaf.cloudflare_record.oaf_alt_mx2
}

moved {
  from = cloudflare_record.oaf_alt_mx3
  to   = module.oaf.cloudflare_record.oaf_alt_mx3
}

moved {
  from = cloudflare_record.oaf_alt_mx4
  to   = module.oaf.cloudflare_record.oaf_alt_mx4
}

moved {
  from = cloudflare_record.oaf_alt_mx5
  to   = module.oaf.cloudflare_record.oaf_alt_mx5
}

moved {
  from = cloudflare_record.oaf_alt_spf
  to   = module.oaf.cloudflare_record.oaf_alt_spf
}

moved {
  from = cloudflare_record.oaf_alt_google_site_verification
  to   = module.oaf.cloudflare_record.oaf_alt_google_site_verification
}

moved {
  from = cloudflare_record.oaf_alt_domainkey_google
  to   = module.oaf.cloudflare_record.oaf_alt_domainkey_google
}

moved {
  from = cloudflare_record.oaf_alt_dmarc
  to   = module.oaf.cloudflare_record.oaf_alt_dmarc
}

moved {
  from = cloudflare_record.oaf_donate
  to   = module.oaf.cloudflare_record.oaf_donate
}

moved {
  from = cloudflare_record.oaf_donate_email
  to   = module.oaf.cloudflare_record.oaf_donate_email
}

moved {
  from = cloudflare_record.oaf_donate_domainkey
  to   = module.oaf.cloudflare_record.oaf_donate_domainkey
}

moved {
  from = cloudflare_record.oaf_donate_spf
  to   = module.oaf.cloudflare_record.oaf_donate_spf
}

moved {
  from = cloudflare_record.oaf_donate_mxa
  to   = module.oaf.cloudflare_record.oaf_donate_mxa
}

moved {
  from = cloudflare_record.oaf_donate_mxb
  to   = module.oaf.cloudflare_record.oaf_donate_mxb
}

moved {
  from = aws_instance.oaf
  to   = module.oaf.aws_instance.oaf
}

moved {
  from = aws_eip.oaf
  to   = module.oaf.aws_eip.oaf
}
