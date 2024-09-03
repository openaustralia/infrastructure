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

module "metabase" {
  source = "./metabase"
  # This security group also lets in port 9000 for staging which we're not using
  # TODO: In fact we're not using port 9000 anywhere behind the load balancer anymore. Get rid of it
  security_group_behind_lb = aws_security_group.planningalerts
  instance_profile         = aws_iam_instance_profile.logging
  ami                      = var.ubuntu_22_ami
  oaf_org_au_zone_id       = var.oaf_org_au_zone_id
  load_balancer            = aws_lb.main
  vpc                      = aws_default_vpc.default
  listener_https           = aws_lb_listener.main-https
}

module "openaustralia" {
  source                   = "./openaustralia"
  security_group_webserver = aws_security_group.webserver
  instance_profile         = aws_iam_instance_profile.logging
  ami                      = var.ubuntu_16_ami
}


moved {
  from = cloudflare_record.oa_root
  to   = module.openaustralia.cloudflare_record.oa_root
}

moved {
  from = cloudflare_record.oa_www
  to   = module.openaustralia.cloudflare_record.oa_www
}

moved {
  from = cloudflare_record.oa_test
  to   = module.openaustralia.cloudflare_record.oa_test
}

moved {
  from = cloudflare_record.oa_blog
  to   = module.openaustralia.cloudflare_record.oa_blog
}

moved {
  from = cloudflare_record.oa_data
  to   = module.openaustralia.cloudflare_record.oa_data
}

moved {
  from = cloudflare_record.oa_software
  to   = module.openaustralia.cloudflare_record.oa_software
}

moved {
  from = cloudflare_record.oa_hackfest
  to   = module.openaustralia.cloudflare_record.oa_hackfest
}

moved {
  from = cloudflare_record.oa_mx
  to   = module.openaustralia.cloudflare_record.oa_mx
}

moved {
  from = cloudflare_record.oa_spf
  to   = module.openaustralia.cloudflare_record.oa_spf
}

moved {
  from = cloudflare_record.oa_cuttlefish_domainkey
  to   = module.openaustralia.cloudflare_record.oa_cuttlefish_domainkey
}

moved {
  from = cloudflare_record.oa_cuttlefish_domainkey2
  to   = module.openaustralia.cloudflare_record.oa_cuttlefish_domainkey2
}

moved {
  from = cloudflare_record.oa_google_domainkey
  to   = module.openaustralia.cloudflare_record.oa_google_domainkey
}

moved {
  from = cloudflare_record.oa_dmarc
  to   = module.openaustralia.cloudflare_record.oa_dmarc
}

moved {
  from = cloudflare_record.oa_alt_root
  to   = module.openaustralia.cloudflare_record.oa_alt_root
}

moved {
  from = cloudflare_record.oa_alt_www
  to   = module.openaustralia.cloudflare_record.oa_alt_www
}

moved {
  from = cloudflare_record.oa_alt_test
  to   = module.openaustralia.cloudflare_record.oa_alt_test
}

moved {
  from = cloudflare_record.oa_alt_www_test
  to   = module.openaustralia.cloudflare_record.oa_alt_www_test
}

moved {
  from = cloudflare_record.oa_alt_data
  to   = module.openaustralia.cloudflare_record.oa_alt_data
}

moved {
  from = cloudflare_record.oa_alt_software
  to   = module.openaustralia.cloudflare_record.oa_alt_software
}

moved {
  from = cloudflare_record.oa_alt_mx
  to   = module.openaustralia.cloudflare_record.oa_alt_mx
}

moved {
  from = cloudflare_record.oa_alt_spf
  to   = module.openaustralia.cloudflare_record.oa_alt_spf
}

moved {
  from = cloudflare_record.oa_alt_google_site_verification
  to   = module.openaustralia.cloudflare_record.oa_alt_google_site_verification
}

moved {
  from = cloudflare_record.oa_alt_facebook_domain_verification
  to   = module.openaustralia.cloudflare_record.oa_alt_facebook_domain_verification
}

moved {
  from = cloudflare_record.oa_alt_domainkey_google
  to   = module.openaustralia.cloudflare_record.oa_alt_domainkey_google
}

moved {
  from = cloudflare_record.oa_alt_dmarc
  to   = module.openaustralia.cloudflare_record.oa_alt_dmarc
}

moved {
  from = aws_instance.openaustralia
  to   = module.openaustralia.aws_instance.openaustralia
}

moved {
  from = aws_eip.openaustralia
  to   = module.openaustralia.aws_eip.openaustralia
}

moved {
  from = aws_ebs_volume.openaustralia_data
  to   = module.openaustralia.aws_ebs_volume.openaustralia_data
}

moved {
  from = aws_volume_attachment.openaustralia_data
  to   = module.openaustralia.aws_volume_attachment.openaustralia_data
}

