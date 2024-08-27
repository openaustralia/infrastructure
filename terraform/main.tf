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
