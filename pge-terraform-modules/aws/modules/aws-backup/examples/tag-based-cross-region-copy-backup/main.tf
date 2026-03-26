/*
 * AWS Backup example - This Example shows how to copy backups to a different region. Resources will be selected based on the tags assigned to them.
 * Terraform module which creates SAF2.0 AWS Backup resources in AWS
 * Pre-requisites - The ARN of a multi-region KMS key and its replicated Key is required.
*/

# Filename    : aws/modules/aws-backup/examples/tag-based-cross-region-copy-backup/main.tf
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

#   count        = var.create_kms_key ? 1 : 0
#   name         = "kms-key-${var.vault_name}"
#   description  = "KMS key for AWS backup vault"
#   tags         = merge(module.tags.tags, local.optional_tags)
#   aws_role     = local.aws_role
#   kms_role     = var.kms_role
#   multi_region = true
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
data "aws_caller_identity" "current" {}


####################################################
# AWS backup Vault
####################################################

module "aws-backup-vault" {
  source = "../../modules/backup-vault/"

  vault_name        = var.vault_name
  vault_kms_key_arn = null # replace with module.kms_key.key_arn, after key creation

  ## Comment out vault notification if not required. Default is disabled.
  create_vault_notifications = var.create_vault_notifications
  sns_topic_arn              = aws_sns_topic.sns-topic-backup-notifications.arn
  backup_vault_events        = var.backup_vault_events

  tags = merge(module.tags.tags, local.optional_tags)
}

####################################################
# Creating cross-region vault
####################################################

module "aws-backup-vault-replica" {
  source = "../../modules/backup-vault/"

  providers = {
    aws = aws.replica
  }

  vault_name        = var.replica_vault_name
  vault_kms_key_arn = null # replace with module.kms_key.key_arn, after key creation

  tags = merge(module.tags.tags, local.optional_tags)
}


####################################################
# AWS backup plan
####################################################

module "aws-backup-plan" {
  source = "../../"

  aws_backup_plan_name = var.aws_backup_plan_name
  aws_backup_plan_rule = [
    {
      rule_name         = var.backup_rule_name
      target_vault_name = module.aws-backup-vault.vault_id
      schedule          = var.backup_rule_schedule
      start_window      = var.backup_rule_start_window
      completion_window = var.backup_rule_completion_window
      lifecycle = {
        delete_after = var.backup_rule_delete_after
      }

      copy_action = [{
        destination_vault_arn = module.aws-backup-vault-replica.vault_arn
        lifecycle = {
          delete_after = var.destination_vault_delete_after
        }
      }]
  }]

  tags = merge(module.tags.tags, local.optional_tags)
}

####################################################
# Tag based resource selection
####################################################

module "aws-backup-resource-selection" {
  source = "../../modules/backup-resource-selection/"

  backup_selection_name = var.backup_selection_name
  plan_id               = module.aws-backup-plan.backup_plan_id
  selection_tags        = var.selection_tags

  #IAM role
  iam_role_arn = module.aws_iam_role.arn
}


#########################################
# IAM role with AWS-backup service policy
#########################################

module "aws_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.iam_role_name != null ? var.iam_role_name : "iam-role-${var.backup_selection_name}"
  policy_arns = concat(var.policy_arns_list, ["arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"])
  aws_service = var.aws_service
  tags        = merge(module.tags.tags, local.optional_tags)
}

#########################################
# Create SNS topic and subscription
#########################################
resource "aws_sns_topic" "sns-topic-backup-notifications" {
  name              = var.snstopic_name
  display_name      = var.snstopic_display_name
  kms_master_key_id = null # replace with module.kms_key.key_arn, after key creation
  tags              = merge(module.tags.tags, local.optional_tags)
}

resource "aws_sns_topic_policy" "sns_trigger_lambda" {
  arn = aws_sns_topic.sns-topic-backup-notifications.arn
  policy = templatefile(
    "${path.module}/${var.sns_policy_file_name}",
    {
      snstopic_name = var.snstopic_name
      account_num   = data.aws_caller_identity.current.account_id
      aws_region    = var.aws_region
  })
}

module "sns_topic_subscription" {
  source  = "app.terraform.io/pgetech/sns/aws//modules/sns_subscription"
  version = "0.1.1"

  endpoint  = var.endpoint
  protocol  = var.protocol
  topic_arn = aws_sns_topic.sns-topic-backup-notifications.arn
}