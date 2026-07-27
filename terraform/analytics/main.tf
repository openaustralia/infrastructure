terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4.0"
    }
  }
}

# Self-hosted Umami analytics (see issue #607). Unlike metabase this does not
# sit behind the shared load balancer: it is a standalone box proxied by
# Cloudflare, so nginx terminates TLS with a Let's Encrypt certificate and the
# tracking script gets cached at Cloudflare's edge.
resource "aws_instance" "main" {
  ami = var.ami

  # Umami is a single Node process. 2GB is comfortable; t3.micro is not.
  instance_type = "t3.small"
  ebs_optimized = true
  key_name      = "terraform"
  tags = {
    Name = "analytics"
  }
  vpc_security_group_ids  = [var.security_group.id]
  disable_api_termination = true
  iam_instance_profile    = var.instance_profile.name
}

resource "aws_eip" "main" {
  instance = aws_instance.main.id
  tags = {
    Name = "analytics"
  }
}
