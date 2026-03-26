/*
 * AWS Backup Example - This Example shows selection of AWS resources based on different selection conditions.
 * Terraform module which creates SAF2.0 AWS Backup resources in AWS
*/

# Filename    : aws/modules/aws-backup/examples/condition-based-resource-selection/main.tf
# Date        : 30 June 2023
# Author      : PGE
# Description : Manages Tag-based conditions used to specify a set of resources to assign to a backup plan.
#

locals {
  optional_tags = var.optional_tags
  Order         = var.Order
}


# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.0.10"

#   count       = var.create_kms_key ? 1 : 0
#   name        = "kms-key-${var.vault_name}"
#   description = "KMS key for AWS backup vault"
#   tags        = merge(module.tags.tags, local.optional_tags)
#   aws_role    = local.aws_role
#   kms_role    = var.kms_role
# }

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
  Order              = local.Order
}

data "aws_partition" "current" {}

####################################################
# AWS backup Vault
####################################################

module "aws-backup-vault" {
  source = "../../modules/backup-vault/"

  vault_name        = var.vault_name
  vault_kms_key_arn = null # replace with module.kms_key.key_arn, after key creation

  tags = merge(module.tags.tags, local.optional_tags)
}

####################################################
# Creating backup plan
####################################################

module "aws-backup-plan" {
  source = "../../"

  aws_backup_plan_name = var.aws_backup_plan_name
  aws_backup_plan_rule = var.aws_backup_plan_rule

  tags = merge(module.tags.tags, local.optional_tags)

  depends_on = [
    module.aws-backup-vault
  ]
}

####################################################
# Condition based resource selection
####################################################

module "aws-backup-resource-selection" {
  source = "../../modules/backup-resource-selection/"

  backup_selection_name = var.backup_selection_name
  plan_id               = module.aws-backup-plan.backup_plan_id
  backup_resources      = ["*"]

  #IAM role
  iam_role_arn = module.aws_iam_role.arn

  string_equals = [{
    key   = "aws:ResourceTag/Component"
    value = "rds"
  }]

  string_like = [{
    key   = "aws:ResourceTag/Application"
    value = "app*"
  }]

  string_not_equals = [{
    key   = "aws:ResourceTag/Backup"
    value = "false"
  }]

  string_not_like = [{
    key   = "aws:ResourceTag/Environment"
    value = "test*"
  }]
}




#########################################
# IAM role 
#########################################

module "aws_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.iam_role_name != null ? var.iam_role_name : "iam-role-${var.backup_selection_name}"
  policy_arns = concat(var.policy_arns_list, ["arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"])
  aws_service = var.aws_service
  tags        = merge(module.tags.tags, local.optional_tags)
}