/*
* # AWS API Gateway Rest api user module using OpenApi example
* Terraform module which creates SAF2.0 API Gateway using OpenApi in AWS
*/

#  Filename    : aws/modules/api-gateway/examples/rest_api_open_api_waf/main.tf
#  Date        : 30 May 2024
#  Author      : PG&E
#  Description : api-gateway terraform module creates a api-gateway with waf rule
#

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
  Order              = var.Order
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

#########################################
# Create API Gateway Resource
#########################################
module "api_gateway_rest_api" {
  source = "../../modules/rest_api_open_api"

  rest_api_name                           = var.rest_api_name
  endpoint_configuration_vpc_endpoint_ids = [var.pVpcEndpoint]
  openapi_config                          = file("${path.module}/test_openapi_spc.json")
  policy                                  = data.aws_iam_policy_document.api_policy.json
  tags                                    = merge(module.tags.tags, local.optional_tags)
}

module "api_gateway_key" {
  source = "../../"

  #aws_api_gateway_key
  api_key_name = var.api_key_name
  tags         = merge(module.tags.tags, local.optional_tags)
}
module "api_gateway_usage_plan" {
  source = "../../modules/api_usage_plan"

  #aws_api_gateway_usage_plan
  usage_plan_name        = var.usage_plan_name
  usage_plan_description = var.usage_plan_description
  tags                   = merge(module.tags.tags, local.optional_tags)
  api_stages = [
    {
      api_id = module.api_gateway_rest_api.api_gateway_rest_api_id
      stage  = module.api_gateway_deployment_and_stage.api_gateway_stage_name
    }
  ]

  #aws_api_gateway_usage_plan_key
  usage_plan_key_id   = module.api_gateway_key.api_gateway_api_key_id
  usage_plan_key_type = var.usage_plan_key_type
}

data "aws_iam_policy_document" "api_policy" {
  source_policy_documents = [
    templatefile("${path.module}/policy.json",
      {
        pVpcEndpoint = var.pVpcEndpoint
    }, )
  ]
}

module "api_gateway_deployment_and_stage" {
  source = "../../modules/open_api_deployment_and_stage"

  deployment_rest_api_id      = module.api_gateway_rest_api.api_gateway_rest_api_id
  stage_name                  = var.stage_name
  stage_cache_cluster_enabled = var.stage_cache_cluster_enabled
  stage_cache_cluster_size    = var.stage_cache_cluster_size
  tags                        = merge(module.tags.tags, local.optional_tags)

  #aws_api_gateway_method_settings
  method_settings_method_path = var.method_settings_method_path
  settings_logging_level      = var.settings_logging_level
}


module "api_gateway_wafv2" {
  source = "../../modules/api_gateway_wafv2"


  web_acl_name               = var.web_acl_name
  webacl_description         = var.webacl_description
  cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
  sampled_requests_enabled   = var.sampled_requests_enabled
  metric_name                = var.metric_name
  request_default_action     = var.request_default_action
  tags                       = merge(module.tags.tags, local.optional_tags)
  custom_response_body = [{
    key          = var.key
    content      = var.content
    content_type = var.content_type
  }]
  # Managed Rules Variables 

  managed_rules = var.managed_rules
  #log_destination_arn = resource.aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn
  log_destination_arn   = var.log_destination_arn
  redacted_fields       = var.redacted_fields
  logging_filter        = var.logging_filter
  api_gateway_stage_arn = module.api_gateway_deployment_and_stage.api_gateway_stage_arn
  enable_waf            = var.enable_waf

}