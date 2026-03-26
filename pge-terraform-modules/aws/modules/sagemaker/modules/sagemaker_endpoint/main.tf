/*
* # AWS sagemaker endpoint module
* # Terraform module which creates Sagemaker endpoint
*/
#
# Filename     : aws/modules/sagemaker/modules/sagemaker_endpoint/main.tf
# Date         : August 30 2022 
# Author       : TCS
# Description  : Terraform sub-module for creation of endpoint in sagemaker
#

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
}

locals {
  namespace = "ccoe-tf-developers"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}


resource "aws_sagemaker_endpoint" "endpoint" {
  name                 = var.name
  endpoint_config_name = var.endpoint_config_name

  dynamic "deployment_config" {
    for_each = var.deployment_config
    content {
      dynamic "auto_rollback_configuration" {
        for_each = lookup(deployment_config.value, "auto_rollback_configuration", {})
        content {
          dynamic "alarms" {
            for_each = auto_rollback_configuration.value.alarms
            content {
              alarm_name = alarms.value["alarm_name"]
            }
          }
        }
      }
      dynamic "blue_green_update_policy" {
        for_each = deployment_config.value.blue_green_update_policy
        content {
          maximum_execution_timeout_in_seconds = lookup(blue_green_update_policy.value, "maximum_execution_timeout_in_seconds", null)
          termination_wait_in_seconds          = lookup(blue_green_update_policy.value, "termination_wait_in_seconds", null)
          dynamic "traffic_routing_configuration" {
            for_each = blue_green_update_policy.value.traffic_routing_configuration
            content {
              type                     = traffic_routing_configuration.value["type"]
              wait_interval_in_seconds = traffic_routing_configuration.value["wait_interval_in_seconds"]
              dynamic "canary_size" {
                for_each = lookup(traffic_routing_configuration.value, "canary_size", {})
                content {
                  type  = canary_size.value["type"]
                  value = canary_size.value["value"]
                }
              }
              dynamic "linear_step_size" {
                for_each = lookup(traffic_routing_configuration.value, "linear_step_size", {})
                content {
                  type  = linear_step_size.value["type"]
                  value = linear_step_size.value["value"]
                }
              }
            }
          }
        }
      }
    }
  }
  tags = local.module_tags

}