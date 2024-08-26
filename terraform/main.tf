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

moved {
  from = cloudflare_record.el_root
  to   = module.electionleaflets.cloudflare_record.el_root
}

moved {
  from = cloudflare_record.el_www
  to   = module.electionleaflets.cloudflare_record.el_www
}

moved {
  from = cloudflare_record.el_test
  to   = module.electionleaflets.cloudflare_record.el_test
}

moved {
  from = cloudflare_record.el_www_test
  to   = module.electionleaflets.cloudflare_record.el_www_test
}

moved {
  from = cloudflare_record.el_federal2010
  to   = module.electionleaflets.cloudflare_record.el_federal2010
}

moved {
  from = cloudflare_record.el_google_domain_verification
  to   = module.electionleaflets.cloudflare_record.el_google_domain_verification
}

moved {
  from = cloudflare_record.el_mx1
  to   = module.electionleaflets.cloudflare_record.el_mx1
}

moved {
  from = cloudflare_record.el_mx2
  to   = module.electionleaflets.cloudflare_record.el_mx2
}

moved {
  from = cloudflare_record.el_mx3
  to   = module.electionleaflets.cloudflare_record.el_mx3
}

moved {
  from = cloudflare_record.el_mx4
  to   = module.electionleaflets.cloudflare_record.el_mx4
}

moved {
  from = cloudflare_record.el_mx5
  to   = module.electionleaflets.cloudflare_record.el_mx5
}

moved {
  from = cloudflare_record.el_mx6
  to   = module.electionleaflets.cloudflare_record.el_mx6
}

moved {
  from = cloudflare_record.el_mx7
  to   = module.electionleaflets.cloudflare_record.el_mx7
}

moved {
  from = cloudflare_record.el_spf
  to   = module.electionleaflets.cloudflare_record.el_spf
}

moved {
  from = cloudflare_record.el_google_site_verification
  to   = module.electionleaflets.cloudflare_record.el_google_site_verification
}

moved {
  from = cloudflare_record.el_domainkey_google
  to   = module.electionleaflets.cloudflare_record.el_domainkey_google
}

moved {
  from = cloudflare_record.el_dmarc
  to   = module.electionleaflets.cloudflare_record.el_dmarc
}

moved {
  from = aws_instance.electionleaflets
  to   = module.electionleaflets.aws_instance.electionleaflets
}

moved {
  from = aws_eip.electionleaflets
  to   = module.electionleaflets.aws_eip.electionleaflets
}

moved {
  from = aws_ebs_volume.electionleaflets_data
  to   = module.electionleaflets.aws_ebs_volume.electionleaflets_data
}

moved {
  from = aws_volume_attachment.electionleaflets_data
  to   = module.electionleaflets.aws_volume_attachment.electionleaflets_data
}

moved {
  from = aws_iam_user.electionleaflets
  to   = module.electionleaflets.aws_iam_user.electionleaflets
}

moved {
  from = aws_iam_policy.electionleaflets
  to   = module.electionleaflets.aws_iam_policy.electionleaflets
}

moved {
  from = aws_iam_user_policy_attachment.electionleaflets
  to   = module.electionleaflets.aws_iam_user_policy_attachment.electionleaflets
}

moved {
  from = aws_s3_bucket.production
  to   = module.electionleaflets.aws_s3_bucket.production
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.production
  to   = module.electionleaflets.aws_s3_bucket_server_side_encryption_configuration.production
}

moved {
  from = aws_s3_bucket_acl.production
  to   = module.electionleaflets.aws_s3_bucket_acl.production
}

moved {
  from = aws_s3_bucket.staging
  to   = module.electionleaflets.aws_s3_bucket.staging
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.staging
  to   = module.electionleaflets.aws_s3_bucket_server_side_encryption_configuration.staging
}

moved {
  from = aws_s3_bucket_acl.staging
  to   = module.electionleaflets.aws_s3_bucket_acl.staging
}
