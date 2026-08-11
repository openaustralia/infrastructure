# Cloudflare Tunnel for the blue/green fleet, currently used only for the www-test/api-test
# hostnames while the tunnel setup is validated - www, api and the base domain stay as CNAMEs
# to the ELB for now (see dns.tf). No "primary" tunnel yet - that's a separate, later change
# once the test tunnel has proven itself.

resource "random_id" "planningalerts_test_tunnel_secret" {
  byte_length = 32
}

resource "cloudflare_tunnel" "planningalerts_test" {
  account_id = var.cloudflare_account_id
  name       = "planningalerts-test"
  secret     = random_id.planningalerts_test_tunnel_secret.b64_std
}

resource "cloudflare_tunnel_config" "planningalerts_test" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.planningalerts_test.id

  config {
    ingress_rule {
      hostname = "www-test.planningalerts.org.au"
      service  = "http://localhost:8000"
    }

    ingress_rule {
      hostname = "api-test.planningalerts.org.au"
      service  = "http://localhost:8000"
    }

    # Mandatory catch-all - must be last
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "aws_ssm_parameter" "planningalerts_test_tunnel_token" {
  name  = "/planningalerts/test_tunnel_token"
  type  = "SecureString"
  value = cloudflare_tunnel.planningalerts_test.tunnel_token
}
