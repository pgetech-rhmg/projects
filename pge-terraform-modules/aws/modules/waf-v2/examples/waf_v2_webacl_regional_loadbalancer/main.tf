/*
 * # AWS WAF web acl regional module example
*/
#
# Filename    : aws/modules/waf-v2/examples/waf_v2_webacl_regional_loadbalancer/main.tf
# Date        : 7 March 2022
# Author      : TCS
# Description : WAF web acl regional usage creation with loadbalancer.
#

locals {
  name  = "${var.name}-${random_string.name.result}"
  Order = var.Order
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

data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.subnet_id1_name
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.subnet_id2_name
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

#########################################
# Create WAF Ipset
#########################################
module "wafv2_ip_set" {
  source = "../../modules/wafv2_ip_set_regional"

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
  source = "../../modules/wafv2_web_acl_regional"

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

  # Ip set rules variables

  ipset_reference_rules = [
    {
      name     = "ip_set_rule"
      priority = 11
      action   = "block"
      custom_response = {
        custom_response_body_key = "sample"
        response_code            = 403
        response_header = [{
          name  = "sample"
          value = "test"
        }]
      }
      statement = {
        arn = module.wafv2_ip_set.ip_set_arn
        ip_set_forwarded_ip_config = {
          fallback_behavior = "NO_MATCH"
          header_name       = "test"
          position          = "FIRST"
        }
      }
      rule_label = [{
        name = "label1"
        },
        {
          name = "label2"
      }]
      visibility_config = [{
        metric_name = "metric"
      }]
    },
    {
      name     = "ip_set_rule2"
      priority = 12
      action   = "block"
      custom_response = {
        custom_response_body_key = "sample"
        response_code            = 403
        response_header = [{
          name  = "sample"
          value = "test"
        }]
      }
      statement = {
        arn = module.wafv2_ip_set.ip_set_arn
        ip_set_forwarded_ip_config = {
          fallback_behavior = "MATCH"
          header_name       = "header2"
          position          = "LAST"
        }
      }
      rule_label = [{
        name = "label3"
      }]
      visibility_config = [{
        metric_name = "metric1"
      }]
  }]

  # Rate based Rules
  rate_based_rules = [
    {
      name     = "rate_based_rule-1"
      priority = 19

      action = "block"
      custom_response = {
        custom_response_body_key = "sample"
        response_code            = 403
        response_header = [{
          name  = "sample-header-1"
          value = "test-header-1"
          },
          {
            name  = "sample-header-2"
            value = "test-header-2"
          }
        ]
      }

      #rate based statement
      statement = {
        limit              = 100
        aggregate_key_type = "IP"
        forwarded_ip_config = {
          fallback_behavior = "NO_MATCH"
          header_name       = "test"
        }
        scope_down_statement = [{
          geo_match_statement = {
            country_codes = ["US", "NL"]
            forwarded_ip_config = {
              fallback_behavior = "MATCH"
              header_name       = "header3"
            }
          }
        }]
      }

      rule_label = [{
        name = "label8"
        },
        {
          name = "label9"
      }]
      visibility_config = [{
        metric_name = "metric"
      }]
    }
  ]

  # geo_match_statement_rule
  geo_match_statement_rules = var.geo_match_statement_rules

  # label_match_statement_rule
  label_match_statement_rules = var.label_match_statement_rules

  # byte_match_statement_rule
  byte_match_rule = var.byte_match_rule

  # xss_match_statement_rule
  xss_match_rule = var.xss_match_rule

  # Managed Rules Variables - Simple demonstration of IPSet integration
  managed_rules = var.managed_rules
  log_destination_arn = resource.aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn
  redacted_fields     = var.redacted_fields
  logging_filter      = var.logging_filter

  # Web-acl association with loadbalancer

  enable_webacl_resource_association     = var.enable_webacl_resource_association
  resource_arn_to_associate_with_web_acl = module.alb.lb_arn
  tags                                   = merge(module.tags.tags, var.optional_tags)
}

# module

module "alb" {
  source  = "app.terraform.io/pgetech/alb/aws"
  version = "0.1.2"

  alb_name        = local.name
  bucket_name     = aws_s3_bucket.bucket.bucket
  security_groups = [module.security_group_alb.sg_id]
  subnets         = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  vpc_id          = data.aws_ssm_parameter.vpc_id.value
  tags            = merge(module.tags.tags, var.optional_tags)
}

# security group for alb

module "security_group_alb" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"
  /*  */
  name               = local.name
  description        = var.alb_sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  tags               = merge(module.tags.tags, var.optional_tags)
  cidr_egress_rules  = var.cidr_egress_rules
  cidr_ingress_rules = var.cidr_ingress_rules
}

# Resource Kinesis Firehose and its pre-requisites in the below section, to be replaced with the central logging kinesis stream arn for the each account.

resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = var.aws_kinesis_firehose_delivery_stream_name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = module.aws_iam_role.arn
    bucket_arn = aws_s3_bucket.bucket.arn
  }

  tags = merge(module.tags.tags, var.optional_tags)
}

# Instead of using PG&E s3 module, here we use aws_s3_bucket terraform resource because alb logs cannot be written to a kms-cmk encrypted s3 bucket. So standard encryption is used for the s3 bucket.

resource "aws_s3_bucket" "bucket" {
  bucket        = local.name
  force_destroy = true
  tags          = merge(module.tags.tags, var.optional_tags)
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_alb_encryption" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "s3_default" {
  bucket = aws_s3_bucket.bucket.id
  policy = templatefile("${path.module}/policy.json", { bucket_name = local.name, account_num = var.account_num, aws_role = var.aws_role })
}

module "aws_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = local.name
  tags        = merge(module.tags.tags, var.optional_tags)
  policy_arns = var.policy_arns
  aws_service = var.aws_service
}