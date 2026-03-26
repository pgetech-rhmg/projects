/*
 * # AWS Backup module
 * Terraform module which creates SAF2.0 AWS-Backup resource selections
*/

# Filename    : modules/backup-resource-selection/main.tf
# Date        : 16 June 2023
# Author      : PGE
# Description : Manages Tag-based conditions used to specify a set of resources to assign to a backup plan.
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
  backup_selection_name = var.backup_selection_name
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_backup_selection" "backup_selection" {
  name          = local.backup_selection_name
  iam_role_arn  = var.iam_role_arn
  plan_id       = var.plan_id
  resources     = var.backup_resources
  not_resources = var.not_resources

  dynamic "selection_tag" {
    for_each = toset(var.selection_tags)
    content {
      type  = lookup(selection_tag.value, "type", null)
      key   = lookup(selection_tag.value, "key", null)
      value = lookup(selection_tag.value, "value", null)
    }
  }

  condition {
    dynamic "string_equals" {
      for_each = toset(var.string_equals)
      content {
        key   = lookup(string_equals.value, "key", null)
        value = lookup(string_equals.value, "value", null)
      }
    }
    dynamic "string_like" {
      for_each = toset(var.string_like)
      content {
        key   = lookup(string_like.value, "key", null)
        value = lookup(string_like.value, "value", null)
      }
    }
    dynamic "string_not_equals" {
      for_each = toset(var.string_not_equals)
      content {
        key   = lookup(string_not_equals.value, "key", null)
        value = lookup(string_not_equals.value, "value", null)
      }
    }
    dynamic "string_not_like" {
      for_each = toset(var.string_not_like)
      content {
        key   = lookup(string_not_like.value, "key", null)
        value = lookup(string_not_like.value, "value", null)
      }
    }
  }

}

