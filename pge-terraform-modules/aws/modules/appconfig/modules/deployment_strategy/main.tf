/*
 * # AWS AppConfig module
 * Terraform module which creates SAF2.0 AppConfig deployment strategy in AWS
*/
#
#  Filename    : aws/modules/appconfig/modules/deployment_strategy/main.tf
#  Date        : 29 January 2024
#  Author      : Eric Barnard @e6bo 
#  Description : AppConfig TF module that creates an AppConfig deployment strategy
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

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_appconfig_deployment_strategy" "pge_strategy" {
  name        = var.name
  description = var.description
  tags        = local.module_tags

  replicate_to                   = var.replicate_to
  growth_type                    = var.growth_type
  growth_factor                  = var.growth_factor
  deployment_duration_in_minutes = var.deployment_duration
  final_bake_time_in_minutes     = var.bake_time
}
