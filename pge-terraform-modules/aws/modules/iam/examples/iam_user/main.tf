/*
 * # AWS IAM User module
 * Terraform module which creates SAF2.0 IAM user in AWS
*/
#
# Filename    : modules/iam/examples/iam-user
# Date        : Nov 22, 2021
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : iam user creation
#
locals {
  name                 = var.name
  permissions_boundary = var.permissions_boundary
  AppID                = var.AppID
  Environment          = var.Environment
  DataClassification   = var.DataClassification
  CRIS                 = var.CRIS
  Notify               = var.Notify
  Owner                = var.Owner
  Compliance           = var.Compliance
  Order                = var.Order
  optional_tags        = var.optional_tags
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}


###################################################################
# IAM user without pgp_key, login profiles, access keys 
###################################################################
module "aws_iam_user" {
  source = "../../modules/iam_user"

  name                 = local.name
  permissions_boundary = local.permissions_boundary
  tags                 = merge(module.tags.tags, local.optional_tags)
}

