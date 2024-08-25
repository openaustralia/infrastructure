module "cuttlefish" {
  source             = "./cuttlefish"
  oaf_org_au_zone_id = var.oaf_org_au_zone_id
  cuttlefish_ipv4    = var.cuttlefish_ipv4
  cuttlefish_ipv6    = var.cuttlefish_ipv6
}

moved {
  from = linode_instance.cuttlefish
  to   = module.cuttlefish.linode_instance.cuttlefish
}

moved {
  from = linode_rdns.cuttlefish_ipv4
  to   = module.cuttlefish.linode_rdns.cuttlefish_ipv4
}

moved {
  from = linode_rdns.cuttlefish_ipv6
  to   = module.cuttlefish.linode_rdns.cuttlefish_ipv6
}

moved {
  from = cloudflare_record.oaf_cuttlefish
  to   = module.cuttlefish.cloudflare_record.oaf_cuttlefish
}

moved {
  from = cloudflare_record.oaf_aaaa_cuttlefish
  to   = module.cuttlefish.cloudflare_record.oaf_aaaa_cuttlefish
}

moved {
  from = cloudflare_record.oaf_cuttlefish_mx1
  to   = module.cuttlefish.cloudflare_record.oaf_cuttlefish_mx1
}

moved {
  from = cloudflare_record.oaf_cuttlefish_mx2
  to   = module.cuttlefish.cloudflare_record.oaf_cuttlefish_mx2
}

moved {
  from = cloudflare_record.oaf_cuttlefish_mx3
  to   = module.cuttlefish.cloudflare_record.oaf_cuttlefish_mx3
}

moved {
  from = cloudflare_record.oaf_cuttlefish_mx4
  to   = module.cuttlefish.cloudflare_record.oaf_cuttlefish_mx4
}

moved {
  from = cloudflare_record.oaf_cuttlefish_mx5
  to   = module.cuttlefish.cloudflare_record.oaf_cuttlefish_mx5
}

moved {
  from = cloudflare_record.oaf_cuttlefish_spf
  to   = module.cuttlefish.cloudflare_record.oaf_cuttlefish_spf
}

moved {
  from = cloudflare_record.oaf_cuttlefish_domainkey
  to   = module.cuttlefish.cloudflare_record.oaf_cuttlefish_domainkey
}

moved {
  from = cloudflare_record.oaf_cuttlefish_google_domainkey
  to   = module.cuttlefish.cloudflare_record.oaf_cuttlefish_google_domainkey
}

moved {
  from = cloudflare_record.oaf_domainkey
  to   = module.cuttlefish.cloudflare_record.oaf_domainkey
}

moved {
  from = cloudflare_record.oaf_domainkey2
  to   = module.cuttlefish.cloudflare_record.oaf_domainkey2
}
