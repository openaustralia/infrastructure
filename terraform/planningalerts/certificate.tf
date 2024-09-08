module "certificate" {
  source      = "../aws-certificate"
  domain_name = "planningalerts.org.au"
  subject_alternative_names = [
    "www.planningalerts.org.au",
    "api.planningalerts.org.au"
  ]
  zone_id = cloudflare_zone.main.id
}
