resource "aws_s3_bucket" "main" {
  bucket = "planningalerts-as-${var.env}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
