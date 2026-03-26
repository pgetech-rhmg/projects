/*
 * # AWS SSM module
 * Terraform module which creates SAF2.0 SSM patch-manager Baseline resource in AWS
*/

# Filename    : aws/modules/ssm/examples/ssm-patch-manager-baseline/main.tf
# Date        : 13 April 2023
# Author      : PGE
# Description : The example code will create a SSM patch-manager-baseline resource in AWS and attaches a patch-group to the baseline.
#

locals {
  optional_tags = var.optional_tags
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

#####################################################
# Creating Patch Baseline and patch-group 
#####################################################

module "ssm-patch-manager-baseline" {
  source = "../../modules/patch-manager-baseline"

  ssm_patch_baseline_name           = var.ssm_patch_baseline_name
  operating_system                  = var.operating_system
  approved_patches_compliance_level = var.approved_patches_compliance_level
  patch_baseline_approval_rules     = var.patch_baseline_approval_rules
  set_default_patch_baseline        = var.set_default_patch_baseline

  patch_groups = var.patch_group_names

  tags = merge(module.tags.tags, local.optional_tags)
}