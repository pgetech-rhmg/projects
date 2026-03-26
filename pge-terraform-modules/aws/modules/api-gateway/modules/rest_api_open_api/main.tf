/*
* # AWS API Gateway module using OpenApi
* Terraform module which creates SAF2.0 API Gateway using OpenApi approch in AWS
*/

#  Filename    : aws/modules/api-gateway/modules/rest_api_open_api/main.tf
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

  name       = var.rest_api_name
  body       = var.openapi_config
  policy     = var.policy
  parameters = var.rest_api_parameters
  tags       = local.module_tags

  endpoint_configuration {
    types            = [var.endpoint_configuration_types]
    vpc_endpoint_ids = var.endpoint_configuration_vpc_endpoint_ids
  }
}
