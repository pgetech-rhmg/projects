/*
 * AWS RAM Logically Air Gapped Vault Association Example
 * Terraform module which creates SAF2.0 AWS RAM -Logically Air Gapped Vault Association resources in AWS
*/

# Filename    : aws/modules/ram/examples/ram-association-for-logically-air-gapped-vault/main.tf
# Date        : 25 Mar 2025
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
  source  = "app.terraform.io/pgetech/aws-backup/aws//modules/logically-air-gapped-vault"
  version = "0.0.4"

  vault_name         = var.logically_air_gapped_vault_name
  max_retention_days = local.max_retention_days
  min_retention_days = local.min_retention_days
  tags               = merge(module.tags.tags, local.optional_tags)
}


####################################################
#Creating RAM Share
####################################################

module "aws-ram-share" {
  source = "app.terraform.io/pgetech/ram/aws"

  share_name                = var.share_name
  allow_external_principals = var.allow_external_principals
  tags                      = merge(module.tags.tags, local.optional_tags)
}


#########################################
# RAM Share Association 
#########################################

module "ram-share-association" {
  source = "app.terraform.io/pgetech/ram/aws//modules/ram-associations"

  resource_arns      = [module.air-gapped-vault.vault_arn]
  resource_share_arn = module.aws-ram-share.arn
  principal_ids      = var.principal_ids
}