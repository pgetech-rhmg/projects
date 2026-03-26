/*
 * # AWS route 53 health check module
 * Terraform module which creates SAF2.0 Route 53 health check in AWS. This module can be used in the scenario to check if the route53 designated resource is healthy or not. Example can be found at https://github.com/pgetech/multi-region-ha-dr-assessment/tree/main/acm.tf
*/

#
#  Filename    : aws/modules/Route_53/modules/route53_health_check/main.tf
#  Date        : 23 Sep 2024
#  Author      : s7aw
#  Description : Route 53 terraform module to create route53 health check. This module can be used in the scenario to check if the route53 designated resource is healthy or not. Example can be found at https://github.com/pgetech/multi-region-ha-dr-assessment/tree/main/acm.tf
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

resource "aws_route53_health_check" "example" {
  reference_name                  = var.reference_name
  fqdn                            = var.fqdn
  ip_address                      = var.ip_address
  port                            = var.port
  type                            = var.type
  failure_threshold               = var.failure_threshold
  request_interval                = var.request_interval
  resource_path                   = var.resource_path
  search_string                   = var.search_string
  measure_latency                 = var.measure_latency
  invert_healthcheck              = var.invert_healthcheck
  disabled                        = var.disabled
  enable_sni                      = var.enable_sni
  child_healthchecks              = var.child_healthchecks
  child_health_threshold          = var.child_health_threshold
  cloudwatch_alarm_name           = var.cloudwatch_alarm_name
  cloudwatch_alarm_region         = var.cloudwatch_alarm_region
  insufficient_data_health_status = var.insufficient_data_health_status
  regions                         = var.regions
  routing_control_arn             = var.routing_control_arn
  tags                            = local.module_tags
}


