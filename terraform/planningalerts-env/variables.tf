variable "availability_zones" {
  type = list(string)
}

variable "env_name" {
  description = "Name of this environment (blue or green)"
}

variable "enable" {
  description = "Enable this environment (blue/green)"
  type        = bool
}

variable "instance_count" {
  description = "Number of instances for this environment"
  type        = number
}

variable "ami" {
}

variable "security_groups" {
  type = list(string)
}

variable "iam_instance_profile" {
}

variable "key_name" {
}

variable "vpc_id" {
}
