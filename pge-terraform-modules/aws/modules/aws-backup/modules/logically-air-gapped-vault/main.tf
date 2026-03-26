/*
 * # AWS Backup module
 * Terraform module which creates SAF2.0 AWS Logically Air Gapped Backup Vault
*/

# Filename    : modules/logically-air-gapped-vault/main.tf
# Date        : 24 March 2025
# Author      : PGE
# Description : Provides an AWS Logically Air Gapped Backup Vault Resource. 
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

  vault_name                 = var.vault_name ## Mandatory variable
  max_retention_days         = var.max_retention_days
  min_retention_days         = var.min_retention_days 
  create_vault_policy        = var.create_vault_policy
  create_vault_notifications = var.create_vault_notifications
}
#is this needed?
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_backup_logically_air_gapped_vault" "default" {
  name               = local.vault_name
  max_retention_days = local.max_retention_days
  min_retention_days = local.min_retention_days
  tags               = local.module_tags
}


resource "aws_backup_vault_policy" "vault_policy" {
  count             = local.create_vault_policy ? 1 : 0
  backup_vault_name = aws_backup_logically_air_gapped_vault.default.name
  policy            = var.vault_iam_policy
}

resource "aws_backup_vault_notifications" "vault_notifications" {
  count               = local.create_vault_notifications ? 1 : 0
  backup_vault_name   = aws_backup_logically_air_gapped_vault.default.name
  sns_topic_arn       = var.sns_topic_arn
  backup_vault_events = var.backup_vault_events
}



