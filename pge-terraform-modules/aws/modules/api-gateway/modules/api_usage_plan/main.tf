/*
* # AWS API Gateway Usage Plan
* Terraform module which creates SAF2.0 API Gateway Usage Plan in AWS
*/

#  Filename    : aws/modules/api-gateway/modules/api_usage_plan/main.tf
#  Date        : 9 Febraury 2022
#  Author      : TCS
#  Description : api-gateway terraform module creates a api-gateway usage plan
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
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_api_gateway_usage_plan" "api_gateway_usage_plan" {

  name         = var.usage_plan_name
  description  = var.usage_plan_description
  product_code = var.usage_plan_product_code
  tags         = local.module_tags

  #In the block api_stages the api_id and stage are required
  #The api_stages can now accept multiple api_id & satge
  dynamic "api_stages" {
    for_each = var.api_stages
    content {
      api_id = api_stages.value.api_id
      stage  = api_stages.value.stage

      #The dynamic block throttle is optional in which the argument path is requried
      dynamic "throttle" {
        for_each = lookup(api_stages.value, "throttle", {})
        content {
          path        = throttle.value.path
          burst_limit = lookup(throttle.value, "burst_list", null)
          rate_limit  = lookup(throttle.value, "rate_limit", null)
        }
      }
    }
  }

  #The dyanmic block quota_settings is optional and the arguments limit,offset,period are also optional
  dynamic "quota_settings" {
    for_each = var.api_quota_settings
    content {
      limit  = lookup(quota_settings.value, "limit", null)
      offset = lookup(quota_settings.value, "offset", null)
      period = lookup(quota_settings.value, "period", null)
    }
  }

  #The dyanmic block throttle_settings is optional and the arguments burst_limit,rate_limit are also optional
  dynamic "throttle_settings" {
    for_each = var.api_throttle_settings
    content {
      burst_limit = lookup(throttle_settings.value, "burst_limit", null)
      rate_limit  = lookup(throttle_settings.value, "rate_limit", null)
    }
  }
}

resource "aws_api_gateway_usage_plan_key" "api_gateway_usage_plan_key" {

  count = var.usage_plan_key_type != null ? 1 : 0

  key_id        = var.usage_plan_key_id
  key_type      = var.usage_plan_key_type
  usage_plan_id = aws_api_gateway_usage_plan.api_gateway_usage_plan.id
}