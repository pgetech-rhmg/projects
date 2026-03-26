/*
 * # AWS Glue Trigger module.
 * Terraform module which creates SAF2.0 Glue Trigger in AWS.
*/

#
#  Filename    : aws/modules/glue/modules/glue-trigger/main.tf
#  Date        : 19 August 2022
#  Author      : TCS
#  Description : Glue Trigger Creation
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

# Module      : Creation of Glue Trigger
# Description : This terraform module creates a Glue Trigger.

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



resource "aws_glue_trigger" "glue_trigger" {

  name = var.glue_trigger_name
  type = var.glue_trigger_type

  description       = coalesce(var.glue_trigger_description, format("%s - Managed by Terraform", var.glue_trigger_name))
  enabled           = var.glue_trigger_enabled
  schedule          = var.glue_trigger_schedule
  start_on_creation = var.glue_trigger_start_on_creation
  workflow_name     = var.glue_trigger_workflow_name
  tags              = local.module_tags

  dynamic "actions" {
    for_each = var.glue_trigger_actions

    content {
      job_name               = try(actions.value.job_name, null)
      crawler_name           = try(actions.value.crawler_name, null)
      arguments              = try(actions.value.arguments, null)
      security_configuration = try(actions.value.security_configuration, null)
      timeout                = try(actions.value.timeout, null)

      dynamic "notification_property" {
        for_each = try(actions.value.notification_property, null) != null ? [true] : []
        content {
          notify_delay_after = try(actions.value.notification_property.notify_delay_after, null)
        }
      }
    }
  }

  dynamic "predicate" {
    for_each = var.glue_trigger_predicate
    content {
      conditions {
        job_name         = try(predicate.value.job_name, null)
        state            = try(predicate.value.state, null)
        crawler_name     = try(predicate.value.crawler_name, null)
        crawl_state      = try(predicate.value.crawl_state, null)
        logical_operator = try(predicate.value.logical_operator, "EQUALS")
      }
      logical = try(predicate.value.logical, "AND")
    }
  }

  dynamic "event_batching_condition" {
    for_each = var.event_batching_condition

    content {
      batch_size   = var.event_batching_condition.batch_size
      batch_window = try(var.event_batching_condition.batch_window, 900)
    }
  }

}