/*
 * # AWS IAM Role module
 * Terraform module which creates SAF2.0 IAM Role in AWS
*/
#
# Filename    : modules/iam/examples/role_with_managed_policy
# Date        : Dec 6 , 2021
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : iam role creation with mutliple policy arns
#

locals {
  name               = var.name
  policy_arns        = var.policy_arns
  aws_service        = var.aws_service
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags      = var.optional_tags
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
# Role Creation with AWS managed policy
#########################################

module "aws_iam_role" {
  source      = "../../"
  name        = local.name
  aws_service = local.aws_service
  #Managed_Policy
  policy_arns = local.policy_arns
  tags        = merge(module.tags.tags, local.optional_tags)
}