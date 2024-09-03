module "certificate" {
  source      = "../aws-certificate"
  domain_name = "planningalerts.org.au"
  subject_alternative_names = [
    "www.planningalerts.org.au",
    "api.planningalerts.org.au"
  ]
  zone_id = var.zone_id
}

moved {
  from = aws_acm_certificate.main
  to   = module.certificate.aws_acm_certificate.main
}

moved {
  from = aws_acm_certificate_validation.main
  to   = module.certificate.aws_acm_certificate_validation.main
}

moved {
  from = cloudflare_record.cert-validation
  to   = module.certificate.cloudflare_record.cert_validation
}
