/*
* # AWS API Gateway Rest Api module
* Terraform module which creates SAF2.0 API Gateway Rest Api in AWS
*/

#  Filename    : aws/modules/api-gateway/modules/rest_api/main.tf
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

resource "aws_api_gateway_rest_api" "api_gateway_rest_api" {

  name                         = var.rest_api_name
  description                  = var.rest_api_description
  policy                       = var.policy
  binary_media_types           = var.rest_api_binary_media_types
  minimum_compression_size     = var.rest_api_minimum_compression_size
  api_key_source               = var.rest_api_api_key_source
  disable_execute_api_endpoint = var.rest_api_disable_execute_api_endpoint
  tags                         = local.module_tags

  endpoint_configuration {
    types            = [var.endpoint_configuration_types]
    vpc_endpoint_ids = var.endpoint_configuration_vpc_endpoint_ids
  }
}

resource "aws_api_gateway_model" "api_gateway_model" {

  count = var.model_content_type != null ? 1 : 0

  rest_api_id  = aws_api_gateway_rest_api.api_gateway_rest_api.id
  name         = var.model_name
  description  = var.model_description
  content_type = var.model_content_type
  schema       = var.model_schema
}

resource "aws_api_gateway_gateway_response" "api_gateway_gateway_response" {

  count = var.gateway_response_type != null ? 1 : 0

  rest_api_id         = aws_api_gateway_rest_api.api_gateway_rest_api.id
  response_type       = var.gateway_response_type
  status_code         = var.gateway_status_code
  response_templates  = var.gateway_response_templates
  response_parameters = var.gateway_response_parameters
}

resource "aws_api_gateway_client_certificate" "api_gateway_client_certificate" {

  count = var.api_gateway_client_certificate_create ? 1 : 0

  description = var.client_certificate_description
  tags        = local.module_tags
}

resource "aws_api_gateway_vpc_link" "api_gateway_vpc_link" {

  count = var.vpc_link_name != null ? 1 : 0

  name        = var.vpc_link_name
  description = var.vpc_link_description
  target_arns = var.vpc_link_target_arns
  tags        = local.module_tags
}

resource "aws_api_gateway_documentation_part" "api_gateway_documentation_part" {

  count = var.documentation_part_properties != null ? 1 : 0

  properties  = var.documentation_part_properties
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  location {
    method      = var.location_method
    name        = var.location_name
    path        = var.location_path
    status_code = var.location_status_code
    type        = var.location_type
  }
}

resource "aws_api_gateway_documentation_version" "api_gateway_documentation_version" {

  count = var.documentation_version != null ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  version     = var.documentation_version
  description = var.documentation_description
  depends_on  = [aws_api_gateway_documentation_part.api_gateway_documentation_part]
}

resource "aws_api_gateway_account" "api_gateway_account" {

  count = var.api_gateway_account_create ? 1 : 0

  cloudwatch_role_arn = var.account_cloudwatch_role_arn
}
