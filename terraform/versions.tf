
terraform {
  # 1.9 is the first release where a variable validation condition may refer
  # to another variable, which the paired postal_dkim_record_name /
  # postal_dkim_record_value checks rely on
  required_version = ">= 1.9"
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
      version = "~> 2.3.5"
    }
    linode = {
      source = "linode/linode"
      # version = "..."
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5.0"
    }
  }
}
