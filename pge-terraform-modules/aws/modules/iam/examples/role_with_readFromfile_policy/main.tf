/*
 * # AWS IAM Role module
 * Terraform module which creates SAF2.0 IAM Role in AWS
*/
#
# Filename    : modules/iam/examples/role_with_readFromfile_policy
# Date        : Nov 22, 2021
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : iam role creation with policy from the file
#

locals {
  name               = var.name
  aws_service        = var.aws_service
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
  Order              = var.Order
}

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}


#########################################
# Role Creation with Read From File Policy
#########################################

module "aws_iam_role" {
  source        = "../../"
  aws_service   = local.aws_service
  name          = local.name
  inline_policy = [file("${path.module}/account_role_policy.json")]
  tags          = merge(module.tags.tags, local.optional_tags)
}


