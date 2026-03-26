/*
 * # AWS AppConfig module
 * Terraform module which creates SAF2.0 AppConfig environment in AWS
*/
#
#  Filename    : aws/modules/appconfig/modules/environment/main.tf
#  Date        : 29 January 2024
#  Author      : Eric Barnard @e6bo 
#  Description : AppConfig TF module that creates an AppConfig environment
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

# workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_appconfig_environment" "pge_env" {
  name        = var.name
  description = var.description
  tags        = local.module_tags

  application_id = var.application_id

  dynamic "monitor" {
    for_each = var.monitors
    content {
      alarm_arn      = monitor.value["alarm_arn"]
      alarm_role_arn = lookup(monitor.value, "alarm_role_arn", null)
    }
  }
}

