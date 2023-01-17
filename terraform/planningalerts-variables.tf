variable "planningalerts_enable_blue_env" {
  description = "Enable planningalerts blue environment"
  type        = bool
  default     = true
}

variable "planningalerts_blue_instance_count" {
  description = "Number of instance for blue environment"
  type        = number
  default     = 2
}

variable "planningalerts_blue_ami" {
  # Same as var.ubuntu_22_ami but we can't directly add that here
  default = "ami-0df609f69029c9bdb"
}