/*
* # AWS API Gateway Rest Api Deployment and Stage module
* Terraform module which creates SAF2.0 API Gateway Rest Api Deployment and Stage module in AWS
*/

#  Filename    : aws/modules/api-gateway/modules/rest_api_deployment_and_stage/main.tf
#  Date        : 9 Febraury 2022
#  Author      : TCS
#  Description : api-gateway terraform module creates a api-gateway
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

resource "aws_api_gateway_deployment" "api_gateway_deployment" {

  rest_api_id = var.rest_api_id
  description = var.deployment_description
  triggers    = var.deployment_triggers
  variables   = var.deployment_variables

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_gateway_stage" {

  rest_api_id           = aws_api_gateway_deployment.api_gateway_deployment.rest_api_id
  deployment_id         = aws_api_gateway_deployment.api_gateway_deployment.id
  stage_name            = var.stage_name
  cache_cluster_enabled = var.stage_cache_cluster_enabled
  cache_cluster_size    = var.stage_cache_cluster_size
  client_certificate_id = var.stage_client_certificate_id
  description           = var.stage_description
  documentation_version = var.stage_documentation_version
  variables             = var.stage_variables
  tags                  = local.module_tags
  xray_tracing_enabled  = var.stage_xray_tracing_enabled

  dynamic "access_log_settings" {
    for_each = var.access_log_settings_destination_arn != null && var.access_log_settings_format != null ? [true] : []
    content {
      destination_arn = var.access_log_settings_destination_arn
      format          = var.access_log_settings_format
    }
  }
}

resource "aws_api_gateway_method_settings" "api_gateway_method_settings" {

  count = var.method_settings_method_path != null ? 1 : 0

  rest_api_id = aws_api_gateway_deployment.api_gateway_deployment.rest_api_id
  stage_name  = aws_api_gateway_stage.api_gateway_stage.stage_name
  method_path = var.method_settings_method_path

  settings {
    metrics_enabled                            = true
    logging_level                              = var.settings_logging_level
    data_trace_enabled                         = var.settings_data_trace_enabled
    throttling_burst_limit                     = var.settings_throttling_burst_limit
    throttling_rate_limit                      = var.settings_throttling_rate_limit
    caching_enabled                            = var.settings_caching_enabled
    cache_ttl_in_seconds                       = var.settings_cache_ttl_in_seconds
    cache_data_encrypted                       = true
    require_authorization_for_cache_control    = true
    unauthorized_cache_control_header_strategy = "FAIL_WITH_403"
  }
}

resource "aws_api_gateway_base_path_mapping" "api_gateway_base_path_mapping" {

  count = var.base_path_mapping_domain_name != null ? 1 : 0

  domain_name = var.base_path_mapping_domain_name
  api_id      = aws_api_gateway_deployment.api_gateway_deployment.rest_api_id
  stage_name  = var.base_path_mapping_stage_name
  base_path   = var.base_path_mapping_base_path
}
