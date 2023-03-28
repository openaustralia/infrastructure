variable "planningalerts_enable_blue_env" {
  description = "Enable planningalerts blue environment"
  type        = bool
  default     = true
}

variable "planningalerts_enable_green_env" {
  description = "Enable planningalerts green environment"
  type        = bool
  default     = false
}

variable "planningalerts_blue_weight" {
  description = "Weighting of traffic to send to blue when enabled"
  type = number
  default = 1
}

variable "planningalerts_green_weight" {
  description = "Weighting of traffic to send to green when enabled"
  type = number
  default = 1
}

variable "planningalerts_blue_instance_count" {
  description = "Number of instance for blue environment"
  type        = number
  default     = 2
}

variable "planningalerts_green_instance_count" {
  description = "Number of instance for green environment"
  type        = number
  default     = 2
}

variable "planningalerts_blue_ami" {
  # planningalerts-puma-ubuntu-22.04
  # TODO: Get this dynamically based on the name chosen in packer
  default = "ami-0574a77d61e67436d"
}

variable "planningalerts_green_ami" {
  # planningalerts-ubuntu-22.04
  # TODO: Get this dynamically based on the name chosen in packer
  default = "ami-00d353be9cdd89469"
}