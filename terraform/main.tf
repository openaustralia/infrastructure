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

moved {
  from = cloudflare_record.morph_root
  to   = module.morph.cloudflare_record.morph_root
}

moved {
  from = cloudflare_record.morph_www
  to   = module.morph.cloudflare_record.morph_www
}

moved {
  from = cloudflare_record.morph_api
  to   = module.morph.cloudflare_record.morph_api
}

moved {
  from = cloudflare_record.morph_discuss
  to   = module.morph.cloudflare_record.morph_discuss
}

moved {
  from = cloudflare_record.morph_faye
  to   = module.morph.cloudflare_record.morph_faye
}

moved {
  from = cloudflare_record.morph_help
  to   = module.morph.cloudflare_record.morph_help
}

moved {
  from = cloudflare_record.morph_email
  to   = module.morph.cloudflare_record.morph_email
}

moved {
  from = cloudflare_record.morph_email2
  to   = module.morph.cloudflare_record.morph_email2
}

moved {
  from = cloudflare_record.morph_mx1
  to   = module.morph.cloudflare_record.morph_mx1
}

moved {
  from = cloudflare_record.morph_mx2
  to   = module.morph.cloudflare_record.morph_mx2
}

moved {
  from = cloudflare_record.morph_mx3
  to   = module.morph.cloudflare_record.morph_mx3
}

moved {
  from = cloudflare_record.morph_mx4
  to   = module.morph.cloudflare_record.morph_mx4
}

moved {
  from = cloudflare_record.morph_mx5
  to   = module.morph.cloudflare_record.morph_mx5
}

moved {
  from = cloudflare_record.morph_spf
  to   = module.morph.cloudflare_record.morph_spf
}

moved {
  from = cloudflare_record.morph_google_site_verification
  to   = module.morph.cloudflare_record.morph_google_site_verification
}

moved {
  from = cloudflare_record.morph_domainkey
  to   = module.morph.cloudflare_record.morph_domainkey
}

moved {
  from = cloudflare_record.morph_domainkey2
  to   = module.morph.cloudflare_record.morph_domainkey2
}

moved {
  from = cloudflare_record.morph_google_domainkey
  to   = module.morph.cloudflare_record.morph_google_domainkey
}

moved {
  from = cloudflare_record.morph_dmarc
  to   = module.morph.cloudflare_record.morph_dmarc
}

moved {
  from = linode_instance.morph
  to   = module.morph.linode_instance.morph
}

moved {
  from = linode_rdns.morph_ipv4
  to   = module.morph.linode_rdns.morph_ipv4
}

