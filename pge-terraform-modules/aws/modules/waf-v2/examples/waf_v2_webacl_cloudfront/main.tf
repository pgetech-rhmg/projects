/*
 * # AWS WEB ACL Cloudfront module example
*/
#
# Filename    : aws/modules/waf-v2/examples/waf_v2_webacl_cloudfront/main.tf
# Date        : 7 March 2022
# Author      : TCS
# Description : WAF Web acl cloudfront usage creation main.
#

locals {
  name     = "${var.name}-${random_string.name.result}"
  Order    = var.Order
  aws_role = var.aws_role
  kms_role = var.kms_role
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 5
  upper   = false
  special = false
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = local.Order
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.0"
#  name        = var.kms_name
#  description = var.kms_description
#  tags        = module.tags.tags
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
# }

#########################################
# Create WAF Ipset
#########################################
module "wafv2_ip_set" {
  source = "../../modules/wafv2_ip_set_cloudfront"

  providers = {
    aws = aws.east
  }

  wafv2_ip_set_name               = local.name
  wafv2_ip_set_description        = var.wafv2_ip_set_description
  wafv2_ip_set_ip_address_version = var.wafv2_ip_set_ip_address_version
  wafv2_ip_set_addresses          = var.wafv2_ip_set_addresses
  tags                            = merge(module.tags.tags, var.optional_tags)
}

#########################################
# Create WAF
#########################################

module "wafv2_web_acl" {
  source = "../../"

  providers = {
    aws = aws.east
  }

  webacl_name                = local.name
  webacl_description         = var.webacl_description
  cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
  sampled_requests_enabled   = var.sampled_requests_enabled
  metric_name                = var.metric_name
  request_default_action     = var.request_default_action

  custom_response_body = [{
    key          = "sample"
    content      = "abcdefg"
    content_type = "TEXT_PLAIN"
  }]

  # Managed Rules Variables - Demonstrating both with and without scope_down_statement
  managed_rules = var.managed_rules

  # Custom IP Set Rules - Direct reference to customer-managed IP sets
  ipset_reference_rules = [
    {
      name     = "custom_ipset_rule"  # Like the rule shown in your AWS console
      priority = 41
      action   = "allow"
      statement = {
        arn = module.wafv2_ip_set.ip_set_arn  # Reference the custom IP set created above
      }
      rule_label = [
        {
          name = "custom_ip_allowed"
        }
      ]
      visibility_config = [
        {
          cloudwatch_metrics_enabled = true
          metric_name                = "${local.name}-custom-ip-allow"
          sampled_requests_enabled   = true
        }
      ]
    }
  ]

  log_destination_arn = resource.aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn
  redacted_fields     = var.redacted_fields
  logging_filter      = var.logging_filter
  tags                = merge(module.tags.tags, var.optional_tags)
}

# Resource Kinesis Firehose and its pre-requisites in the below section, to be replaced with the central logging kinesis stream arn for the each account.

resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  provider = aws.east

  name        = var.aws_kinesis_firehose_delivery_stream_name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = module.aws_iam_role.arn
    bucket_arn = module.s3.arn
  }

  tags = merge(module.tags.tags, var.optional_tags)
}

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = local.name
  kms_key_arn = null # replace with module.kms_key.key_arn after key creation
  tags        = merge(module.tags.tags, var.optional_tags)
}

module "aws_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = local.name
  tags        = merge(module.tags.tags, var.optional_tags)
  policy_arns = var.policy_arns
  aws_service = var.aws_service
}