resource "aws_elasticsearch_domain" "main" {
  domain_name           = "main"
  # 6.4 is the current latest on AWS
  elasticsearch_version = "6.4"

  # TODO: Need to think through what a sensible instance type is here
  cluster_config {
    instance_type = "t2.small.elasticsearch"
    # These settings are only for testing/development. For production we'll
    # want to change these settings
    instance_count = 1
    dedicated_master_enabled = false
  }

  ebs_options {
    ebs_enabled = true
    # 10GB is the minimum storage that we can get started with
    # TODO: Figure out what we actually need
    volume_size = 10
  }

  # 14:00 in UTC is 1am Sydney time - things should be pretty quiet then
  snapshot_options {
    automated_snapshot_start_hour = 14
  }

  # For logging in to Kibana
  cognito_options {
    enabled = true
    user_pool_id = "${aws_cognito_user_pool.admins.id}"
    identity_pool_id = "${aws_cognito_identity_pool.admins.id}"
    role_arn = "${aws_iam_role.es.arn}"
  }
}

resource "aws_cognito_user_pool" "admins" {
  name = "OAF Administrators"
  auto_verified_attributes = ["email"]

  schema {
    name = "email"
    attribute_data_type = "String"
    developer_only_attribute = false
    required = true
    mutable = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
}

resource "aws_cognito_user_pool_client" "client" {
  # TODO: Calculate this
  name = "AWSElasticsearch-main-ap-southeast-2-uc5i7l4fa33x5zbrw27azdnuku"

  user_pool_id = "${aws_cognito_user_pool.admins.id}"
  allowed_oauth_flows = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = ["openid", "phone", "profile", "email"]
  # TODO: Calculate these
  callback_urls = ["https://search-main-uc5i7l4fa33x5zbrw27azdnuku.ap-southeast-2.es.amazonaws.com/_plugin/kibana/app/kibana"]
  # TODO: Calculate these
  logout_urls = ["https://search-main-uc5i7l4fa33x5zbrw27azdnuku.ap-southeast-2.es.amazonaws.com/_plugin/kibana/app/kibana"]
  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "oaf"
  user_pool_id = "${aws_cognito_user_pool.admins.id}"
}

resource "aws_cognito_identity_pool" "admins" {
  identity_pool_name = "OAF Administrators"

  cognito_identity_providers {
    client_id = "${aws_cognito_user_pool_client.client.id}"
    # TODO: Figure this out
    provider_name = "cognito-idp.ap-southeast-2.amazonaws.com/ap-southeast-2_IJEBHxSDH"
    server_side_token_check = true
  }
}

resource "aws_iam_role" "es" {
  name = "CognitoAccessForAmazonES"
  description = "Amazon Elasticsearch role for Kibana authentication."
  assume_role_policy = <<EOF
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"es.amazonaws.com"},"Action":"sts:AssumeRole"}]}
EOF
  path = "/service-role/"
}
