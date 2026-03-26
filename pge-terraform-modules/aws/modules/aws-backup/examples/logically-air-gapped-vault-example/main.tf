/*
 * AWS RAM Logically Air Gapped Vault Association Example
 * Terraform module which creates SAF2.0 AWS RAM -Logically Air Gapped Vault Association resources in AWS
*/

# Filename    : aws/modules/ram/examples/ram-association-for-logically-air-gapped-vault/main.tf
# Date        : 27 Mar 2025
# Author      : Sethu Lakshmi (sul3@pge.com)
# Description : Manages RAM share association with Logically Air Gapped vault
#

locals {
  optional_tags = var.optional_tags
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.0"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
}


####################################################
# AWS Logically air gapped backup Vault
####################################################
module "air-gapped-vault" {
  source = "../../modules/logically-air-gapped-vault/"

  vault_name          = var.logically_air_gapped_vault_name
  max_retention_days  = var.max_retention_days
  min_retention_days  = var.min_retention_days
  create_vault_policy = var.create_vault_policy
  vault_iam_policy    = file(var.vault_iam_policy)
  tags                = merge(module.tags.tags, local.optional_tags)
}