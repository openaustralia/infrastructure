variable "service_name" {
  description = "Used as the IAM role name and to derive the instance profile name (\"<service_name>-instance-profile\")"
  type        = string
}

variable "extra_policy_json" {
  description = "Extra inline policy document JSON to attach on top of the CloudWatch Logs/SSM baseline (e.g. from aws_iam_policy_document), or null for none"
  type        = string
  default     = null
}
