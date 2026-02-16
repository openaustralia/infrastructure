variable "webserver_security_group_id" {
  description = "Security group ID for the shared webserver security group"
  type        = string
}

variable "planningalerts_security_group_id" {
  description = "Security group ID for the PlanningAlerts security group"
  type        = string
}
