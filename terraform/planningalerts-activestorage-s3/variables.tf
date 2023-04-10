variable "name" {
  description = "name given to s3 bucket and associated iam user"
  type = string
}

variable "allowed_origins" {
  description = "domains that are allowed to directly upload"
  type = list(string)
}