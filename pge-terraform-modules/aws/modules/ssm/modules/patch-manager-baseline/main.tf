/*
 * # AWS SSM module
 * Terraform module which creates SAF2.0 SSM Patch-Manager Baseline in AWS
*/

# Filename    : modules/patch-manager-baseline/main.tf
# Date        : 13 April 2023
# Author      : PGE
# Description : The module will create a patch baseline and attach a patch group to it.
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

resource "aws_ssm_patch_baseline" "baseline" {
  name             = var.ssm_patch_baseline_name
  description      = var.ssm_patch_baseline_description
  operating_system = var.operating_system

  approved_patches                  = var.approved_patches
  rejected_patches                  = var.rejected_patches
  approved_patches_compliance_level = var.approved_patches_compliance_level
  rejected_patches_action           = var.rejected_patches_action

  dynamic "global_filter" {
    for_each = toset(var.patch_baseline_global_filter)
    content {
      key    = global_filter.value.key
      values = global_filter.value.values
    }
  }

  dynamic "approval_rule" {
    for_each = toset(var.patch_baseline_approval_rules)
    content {

      approve_after_days  = lookup(approval_rule.value, "approve_after_days", 7)
      compliance_level    = lookup(approval_rule.value, "compliance_level", "HIGH")
      enable_non_security = lookup(approval_rule.value, "enable_non_security", true)

      dynamic "patch_filter" {
        for_each = approval_rule.value.patch_baseline_filters

        content {
          key    = patch_filter.value.name
          values = patch_filter.value.values
        }
      }
    }
  }
  tags = local.module_tags
}

resource "aws_ssm_default_patch_baseline" "default_patch_baseline" {
  count            = var.set_default_patch_baseline ? 1 : 0
  baseline_id      = aws_ssm_patch_baseline.baseline.id
  operating_system = aws_ssm_patch_baseline.baseline.operating_system
}

resource "aws_ssm_patch_group" "patchgroup" {
  count       = length(var.patch_groups)
  baseline_id = aws_ssm_patch_baseline.baseline.id
  patch_group = element(var.patch_groups, count.index)
}

