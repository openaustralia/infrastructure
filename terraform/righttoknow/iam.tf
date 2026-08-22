data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_kms_alias" "ssm" {
  name = "alias/aws/ssm"
}

# Scoped to this service's own SSM parameters only (e.g. Cloudflare tunnel tokens) - not
# blanket SSM parameter access.
data "aws_iam_policy_document" "righttoknow_read_own_parameters" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/righttoknow/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
    ]

    resources = [
      data.aws_kms_alias.ssm.target_key_arn,
    ]
  }
}

module "instance_role" {
  source            = "../service-instance-role"
  service_name      = "righttoknow"
  extra_policy_json = data.aws_iam_policy_document.righttoknow_read_own_parameters.json
}
