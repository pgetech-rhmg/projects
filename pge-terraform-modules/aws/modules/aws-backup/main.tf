/*
 * # AWS Backup module
 * Terraform module which creates SAF2.0 AWS-Backup resources in AWS
*/

# Filename    : modules/aws-backup/main.tf
# Date        : 15 June 2023
# Author      : PGE
# Description : The module creates AWS Backup resources in AWS
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
  namespace            = "ccoe-tf-developers"
  module_tags          = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  aws_backup_plan_name = var.aws_backup_plan_name
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_backup_plan" "default" {
  name = local.aws_backup_plan_name

  dynamic "rule" {
    for_each = toset(var.aws_backup_plan_rule)
    content {
      rule_name                = lookup(rule.value, "rule_name", "Default")
      target_vault_name        = lookup(rule.value, "target_vault_name", "Default")
      schedule                 = lookup(rule.value, "schedule", null)
      enable_continuous_backup = lookup(rule.value, "enable_continuous_backup", null)
      start_window             = lookup(rule.value, "start_window", null)
      completion_window        = lookup(rule.value, "completion_window", null)
      recovery_point_tags      = local.module_tags


      dynamic "lifecycle" {
        for_each = lookup(rule.value, "lifecycle", null) != null ? [1] : [0]
        content {
          delete_after       = lookup(rule.value.lifecycle, "delete_after", null)
          cold_storage_after = lookup(rule.value.lifecycle, "cold_storage_after", null)
        }
      }

      dynamic "copy_action" {
        for_each = lookup(rule.value, "copy_action", null) != null ? rule.value.copy_action : []
        content {
          destination_vault_arn = lookup(copy_action.value, "destination_vault_arn", null)

          dynamic "lifecycle" {
            for_each = lookup(copy_action.value, "lifecycle", null) != null ? [true] : []
            content {
              delete_after       = lookup(copy_action.value.lifecycle, "delete_after", null)
              cold_storage_after = lookup(copy_action.value.lifecycle, "cold_storage_after", null)
            }
          }
        }
      }
    }
  }

  dynamic "advanced_backup_setting" {
    for_each = var.windows_vss_backup ? [1] : [] ## windows_vss_backup is false by default
    content {
      resource_type = "EC2"
      backup_options = {
        WindowsVSS = "enabled"
      }
    }
  }

  tags = local.module_tags
}
