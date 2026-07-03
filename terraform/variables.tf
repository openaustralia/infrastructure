# Note that currently there is duplication between this value and the
# one stored in ansible (group_vars/all.yml). The same secret is rendered
# into terraform/secrets.auto.tfvars by `make tf-secrets` from 1Password.
# TODO: Remove duplication

variable "ec2_region" {
  # Sydney
  default = "ap-southeast-2"
}

variable "rds_admin_password" {
  sensitive = true
}

# External service tokens, rendered into secrets.auto.tfvars from 1Password by
# `make tf-secrets` and consumed by the cloudflare and linode providers.
variable "cloudflare_api_token" {
  sensitive = true
}

variable "linode_api_token" {
  sensitive = true
}

# AMI for Ubuntu 16.04 LTS, locked to a specific version so that we don't
# keep re-provisioning the servers when the AMI gets updated
variable "ubuntu_16_ami" {
  # Name: ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180205
  # Created by: Canonical
  # Virtualization type: hvm
  default = "ami-e1c43f83"
}

# AMI for Ubuntu 18.04 LTS, locked to a specific version so that we don't
# keep re-provisioning the servers when the AMI gets updated
variable "ubuntu_18_ami" {
  # Name: ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20220131
  # Created by: Canonical
  # Virtualization type: hvm
  default = "ami-0510efc4f138a88e1"
}

# AMI for Ubuntu 20.04 LTS, locked to a specific version so that we don't
# keep re-provisioning the servers when the AMI gets updated
variable "ubuntu_20_ami" {
  # Created by: Canonical
  # Virtualization type: hvm
  default = "ami-0b7dcd6e6fd797935"
}

# AMI for Ubuntu 22.04 LTS, locked to a specific version so that we don't
# keep re-provisioning the servers when the AMI gets updated
variable "ubuntu_22_ami" {
  # Created by: Canonical
  # Virtualization type: hvm
  default = "ami-0df609f69029c9bdb"
}

# AMI for Ubuntu 24.04 LTS, locked to a specific version so that we don't
# keep re-provisioning the servers when the AMI gets updated
variable "ubuntu_24_ami" {
  # Created by: Canonical
  # Virtualization type: hvm
  # 64-bit x86
  default = "ami-001f2488b35ca8aad"
}

# AMI for Ubuntu 22.04 LTS (used by OpenVPN server), locked to a specific version
# so that we don't keep re-provisioning the servers when the AMI gets updated
variable "ubuntu_22_openvpn_ami" {
  # Created by: Canonical
  # Virtualization type: hvm
  # 64-bit x86
  default = "ami-0c73bd9145b5546f5"
}

variable "cloudflare_account_id" {
  default = "668e6ebb9952c26ec3c17a85fb3a25a1"
}

# =============================================================================
# Cloudflare-only restrictions
# When enabled, adds security group rules to allow HTTP/HTTPS only from Cloudflare IPs
# Note: You must also remove the 0.0.0.0/0 rules from the SG to enforce the restriction
# =============================================================================

variable "theyvoteforyou_cloudflare_only" {
  description = "Add Cloudflare IP rules to theyvoteforyou security group"
  type        = bool
  default     = false
}

variable "righttoknow_cloudflare_only" {
  description = "Add Cloudflare IP rules to righttoknow security group"
  type        = bool
  default     = false
}

variable "openaustralia_cloudflare_only" {
  description = "Add Cloudflare IP rules to openaustralia security group"
  type        = bool
  default     = false
}

variable "planningalerts_cloudflare_only" {
  description = "Add Cloudflare IP rules to planningalerts load balancer security group"
  type        = bool
  default     = false
}

