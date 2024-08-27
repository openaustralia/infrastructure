// BLUE environment

variable "planningalerts_enable_blue_env" {
  description = "Enable planningalerts blue environment"
  type        = bool
  default     = true
}

variable "planningalerts_blue_weight" {
  description = "Weighting of traffic to send to blue when enabled"
  type        = number
  default     = 1
}

variable "planningalerts_blue_instance_count" {
  description = "Number of instance for blue environment"
  type        = number
  default     = 2
}

variable "planningalerts_blue_ami_name" {
  default = "planningalerts-ruby-3.3-v1"
}

// GREEN environment

variable "planningalerts_enable_green_env" {
  description = "Enable planningalerts green environment"
  type        = bool
  default     = false
}

variable "planningalerts_green_weight" {
  description = "Weighting of traffic to send to green when enabled"
  type        = number
  default     = 0
}

variable "planningalerts_green_instance_count" {
  description = "Number of instance for green environment"
  type        = number
  default     = 2
}

variable "planningalerts_green_ami_name" {
  default = "planningalerts-puma-ubuntu-22.04-v4"
}

// Other configuration

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

