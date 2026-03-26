/*
 * # AWS Backup module
 * Terraform module which creates SAF2.0 AWS Backup Restore Testing feature
*/

# Filename    : modules/backup-restore-testing/main.tf
# Date        : 8 Apr 2025
# Author      : PGE
# Description : Provides an AWS Backup Restore Testing Resource. 
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

resource "aws_backup_restore_testing_plan" "default" {

  name = var.restore_plan_name ## Mandatory variable
  recovery_point_selection {
    algorithm            = var.algorithm
    include_vaults       = var.include_vaults
    exclude_vaults = var.exclude_vaults
    selection_window_days = var.selection_window_days
    recovery_point_types = var.recovery_point_types
  }

  schedule_expression = var.schedule_expression # Daily at 12:00
  schedule_expression_timezone = var.schedule_expression_timezone
  start_window_hours = var.start_window_hours
  tags               = local.module_tags
}


resource "aws_backup_restore_testing_selection" "default" {
  name = var.resource_selection_name

  restore_testing_plan_name = aws_backup_restore_testing_plan.default.name
  protected_resource_type   = var.resource_type
  iam_role_arn              = var.resource_role_arn

  protected_resource_arns = var.resource_arns
  validation_window_hours = var.validation_window_hours
  restore_metadata_overrides = var.enable_restore_metadata_overrides ? var.restore_metadata_overrides : null
  dynamic "protected_resource_conditions" {
    for_each = var.protected_resource_conditions !=null ? [var.protected_resource_conditions] : []
    content {
      dynamic "string_equals" {
        for_each = protected_resource_conditions.value.string_equals != null ? protected_resource_conditions.value.string_equals : []
        content {
          key = string_equals.value.key
          value = string_equals.value.value
        }
      }

      dynamic "string_not_equals" {
        for_each = protected_resource_conditions.value.string_not_equals != null ? protected_resource_conditions.value.string_not_equals : []
        content {
          key = string_not_equals.value.key
          value = string_not_equals.value.value
        }
      }
    }
  }
}



