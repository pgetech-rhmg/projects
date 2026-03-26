/*
* # AWS API Gateway deployment and stage module using OpenApi
* Terraform module which creates SAF2.0 API Gateway deployment and stage using OpenApi approch in AWS
*/

#  Filename    : aws/modules/api-gateway/modules/api_gateway_wafv2/main.tf
#  Date        : 30 May 2024
#  Author      : PGE
#  Description : api-gateway terraform module creates a api-gateway with Waf
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  namespace   = "ccoe-tf-developers"
  name        = var.web_acl_name
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

module "wafv2_web_acl" {
  source  = "app.terraform.io/pgetech/waf-v2/aws//modules/wafv2_web_acl_regional"
  version = "0.1.0"
  #count = var.enable_waf ? 1:0

  webacl_name                = local.name
  webacl_description         = var.webacl_description
  cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
  sampled_requests_enabled   = var.sampled_requests_enabled
  metric_name                = var.metric_name
  request_default_action     = var.request_default_action
  tags                       = local.module_tags
  custom_response_body = [{
    key          = var.key
    content      = var.content
    content_type = var.content_type
    }
  ]
  # Managed Rules Variables 

  managed_rules = var.managed_rules
  #log_destination_arn = resource.aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn
  log_destination_arn = var.log_destination_arn
  redacted_fields     = var.redacted_fields
  logging_filter      = var.logging_filter

}

resource "aws_wafv2_web_acl_association" "waf2_web_acl_association" {
  count        = var.enable_waf ? 1 : 0
  resource_arn = var.api_gateway_stage_arn
  web_acl_arn  = module.wafv2_web_acl.arn
}
