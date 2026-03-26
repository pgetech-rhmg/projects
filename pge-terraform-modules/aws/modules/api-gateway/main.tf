/*
* # AWS API Gateway Api Key
* Terraform module which creates SAF2.0 API Gateway Rest Api in AWS
*/

#  Filename    : aws/modules/api-gateway/modules/api_key/main.tf
#  Date        : 9 Febraury 2022
#  Author      : TCS
#  Description : api-gateway terraform module creates a api-gateway api key
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

resource "aws_api_gateway_api_key" "api_gateway_api_key" {

  name        = var.api_key_name
  description = var.api_key_description
  enabled     = var.api_key_enabled
  value       = var.api_key_value
  tags        = local.module_tags
}