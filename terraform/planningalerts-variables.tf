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
  default = "planningalerts-puma-ubuntu-22.04-v3"
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
  default = "planningalerts-puma-ubuntu-22.04-v3"
}
