module "cuttlefish" {
  source  = "./cuttlefish"
  zone_id = cloudflare_zone.oaf_org_au.id
}

# Replacement for cuttlefish (see docs/postal-migration.md)
module "postal" {
  source         = "./postal"
  zone_id        = cloudflare_zone.oaf_org_au.id
  authorized_key = data.external.id_rsa.result["id_rsa"]
  # TODO(postal setup): set from `postal default-dkim-record` on the box
  # return_path_dkim_record = "k=rsa; p=..."
}

module "docs-internal" {
  source  = "./docs-internal"
  zone_id = cloudflare_zone.oaf_org_au.id
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
  cloudflare_account_id         = var.cloudflare_account_id
  instance_count                = 2
  # TODO(postal cutover): set from the postal web interface once the
  # planningalerts.org.au domain is added there
  # postal_dkim_record_name  = "postal-<tag>._domainkey.planningalerts.org.au"
  # postal_dkim_record_value = "k=rsa; p=..."
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
  source                 = "./theyvoteforyou"
  ami                    = var.ubuntu_20_ami
  deployer_key           = aws_key_pair.deployer
  security_group         = aws_security_group.webserver
  security_group_service = aws_security_group.theyvoteforyou
  instance_profile       = aws_iam_instance_profile.logging
  cloudflare_account_id  = var.cloudflare_account_id
  # TODO(postal cutover): set from the postal web interface once the
  # theyvoteforyou.org.au domain is added there
  # postal_dkim_record_name  = "postal-<tag>._domainkey.theyvoteforyou.org.au"
  # postal_dkim_record_value = "k=rsa; p=..."
}

module "righttoknow" {
  source                        = "./righttoknow"
  security_group_webserver      = aws_security_group.webserver
  security_group_service        = aws_security_group.righttoknow
  security_group_incoming_email = aws_security_group.incoming_email
  instance_profile              = aws_iam_instance_profile.logging
  cloudflare_account_id         = var.cloudflare_account_id
  # This has been upgraded in place to Ubuntu 18.04
  ami           = var.ubuntu_16_ami
  ubuntu_22_ami = var.ubuntu_22_ami
}

module "morph" {
  source                = "./morph"
  cloudflare_account_id = var.cloudflare_account_id
  # TODO(postal cutover): set from the postal web interface once the
  # morph.io domain is added there
  # postal_dkim_record_name  = "postal-<tag>._domainkey.morph.io"
  # postal_dkim_record_value = "k=rsa; p=..."
}

module "metabase" {
  source                   = "./metabase"
  security_group_behind_lb = aws_security_group.planningalerts
  instance_profile         = aws_iam_instance_profile.logging
  ami                      = var.ubuntu_22_ami
  zone_id                  = cloudflare_zone.oaf_org_au.id
  load_balancer            = aws_lb.main
  vpc                      = aws_default_vpc.default
  listener_https           = aws_lb_listener.main-https
}

module "openaustralia" {
  source                   = "./openaustralia"
  security_group_webserver = aws_security_group.webserver
  security_group_service   = aws_security_group.openaustralia
  instance_profile         = aws_iam_instance_profile.logging
  ami                      = var.ubuntu_16_ami
  ubuntu_22_ami            = var.ubuntu_22_ami
  ubuntu_24_ami            = var.ubuntu_24_ami
  cloudflare_account_id    = var.cloudflare_account_id
  # TODO(postal cutover): set from the postal web interface once the
  # openaustralia.org domain is added there
  # postal_dkim_record_name  = "postal-<tag>._domainkey.openaustralia.org"
  # postal_dkim_record_value = "k=rsa; p=..."
}

module "oaf" {
  source                                 = "./oaf"
  oaf_org_au_zone_id                     = cloudflare_zone.oaf_org_au.id
  openaustraliafoundation_org_au_zone_id = cloudflare_zone.openaustraliafoundation_org_au.id
  openaustralia_main_ip                  = module.openaustralia.main_public_ip
  openaustralia_production_ip            = module.openaustralia.production_public_ip
  righttoknow_production_ip              = module.righttoknow.production_public_ip
  righttoknow_staging_ip                 = module.righttoknow.staging_public_ip
  cuttlefish_ip                          = module.cuttlefish.ipv4_address
  # TODO(postal cutover): set from the postal web interface once the
  # oaf.org.au domain is added there (wordpress mail)
  # postal_dkim_record_name  = "postal-<tag>._domainkey.oaf.org.au"
  # postal_dkim_record_value = "k=rsa; p=..."
}

module "campaign-monitor" {
  source  = "./campaign-monitor"
  zone_id = cloudflare_zone.oaf_org_au.id
}

module "raisely" {
  source  = "./raisely"
  zone_id = cloudflare_zone.oaf_org_au.id
}

module "proxy" {
  source           = "./proxy"
  ami              = var.ubuntu_16_ami
  instance_profile = aws_iam_instance_profile.logging
  zone_id          = cloudflare_zone.oaf_org_au.id
}

module "social" {
  source  = "./social"
  zone_id = cloudflare_zone.oaf_org_au.id
}
