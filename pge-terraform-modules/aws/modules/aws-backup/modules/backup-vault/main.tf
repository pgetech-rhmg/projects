/*
 * # AWS Backup module
 * Terraform module which creates SAF2.0 AWS-Backup Vault
 * A backup vault is a container that stores and organizes your backups.
*/

# Filename    : modules/backup-vault/main.tf
# Date        : 29 June 2023
# Author      : PGE
# Description : Provides an AWS Backup vault resource. 
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

  vault_name                 = var.vault_name                 ## Mandatory variable
  enable_vault_lock          = var.enable_vault_lock          ## false by default
  create_vault_policy        = var.create_vault_policy        ## false by default
  create_vault_notifications = var.create_vault_notifications ## false by default
  vault_kms_key_arn          = var.vault_kms_key_arn          ## Mandatory variable
  force_destroy              = var.force_destroy              ## false by default
}

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.vault_kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_backup_vault" "default" {
  name          = local.vault_name
  kms_key_arn   = local.vault_kms_key_arn
  force_destroy = local.force_destroy
  tags          = local.module_tags
}

resource "aws_backup_vault_lock_configuration" "vault_lock_configuration" {
  count               = local.enable_vault_lock ? 1 : 0
  backup_vault_name   = aws_backup_vault.default.name
  changeable_for_days = var.changeable_for_days
  max_retention_days  = var.max_retention_days
  min_retention_days  = var.min_retention_days
}

resource "aws_backup_vault_policy" "vault_policy" {
  count             = local.create_vault_policy ? 1 : 0
  backup_vault_name = aws_backup_vault.default.name
  policy            = var.vault_iam_policy
}

resource "aws_backup_vault_notifications" "vault_notifications" {
  count               = local.create_vault_notifications ? 1 : 0
  backup_vault_name   = aws_backup_vault.default.name
  sns_topic_arn       = var.sns_topic_arn
  backup_vault_events = var.backup_vault_events
}



