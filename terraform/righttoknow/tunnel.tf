# Cloudflare Tunnel for staging.righttoknow - a lower-stakes dry run of the same approach
# being trialled for planningalerts (see ,todo.md). One tunnel, swappable origin: Ansible
# points cloudflared at this EC2 box's own nginx (port 8000) to validate the process; the
# same token can also be run manually against a local Puma dev server to validate
# Puma-specific remote_ip behaviour - never both at once (see ,todo.md).

resource "random_id" "righttoknow_staging_test_tunnel_secret" {
  byte_length = 32
}

resource "cloudflare_tunnel" "righttoknow_staging_test" {
  account_id = var.cloudflare_account_id
  name       = "righttoknow-staging-test"
  secret     = random_id.righttoknow_staging_test_tunnel_secret.b64_std
}

resource "cloudflare_tunnel_config" "righttoknow_staging_test" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.righttoknow_staging_test.id

  config {
    ingress_rule {
      hostname = "staging-test.righttoknow.org.au"
      service  = "http://localhost:8000"
    }

    # Mandatory catch-all - must be last
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "aws_ssm_parameter" "righttoknow_staging_test_tunnel_token" {
  name  = "/righttoknow/staging_test_tunnel_token"
  type  = "SecureString"
  value = cloudflare_tunnel.righttoknow_staging_test.tunnel_token
}
