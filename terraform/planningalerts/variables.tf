// BLUE environment

variable "blue_enabled" {
  description = "Enable planningalerts blue environment"
  type        = bool
}

variable "blue_weight" {
  description = "Weighting of traffic to send to blue when enabled"
  type        = number
}

variable "blue_ami_name" {}

// GREEN environment

variable "green_enabled" {
  description = "Enable planningalerts green environment"
  type        = bool
}

variable "green_weight" {
  description = "Weighting of traffic to send to green when enabled"
  type        = number
}

variable "green_ami_name" {}

// Other configuration

variable "instance_count" {
  description = "Number of instances for each environment (blue/green)"
  type        = number
}

variable "instance_profile" {}
# Not sure if it's better to pass this in or whether this module should just make its own version of it
variable "security_group_incoming_email" {}
variable "deployer_key" {}
variable "load_balancer" {}
variable "security_group_postgresql" {}
variable "rds_monitoring_role" {}
variable "rds_admin_password" {}
variable "listener_http" {}
variable "listener_https" {}
variable "security_group_behind_lb" {}
variable "vpc" {}
variable "availability_zones" {
  type = list(string)
}
variable "cloudflare_account_id" {}
