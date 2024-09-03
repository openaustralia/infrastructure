
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.62.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0.0"
    }
    linode = {
      source = "linode/linode"
      # version = "..."
    }
  }
}
