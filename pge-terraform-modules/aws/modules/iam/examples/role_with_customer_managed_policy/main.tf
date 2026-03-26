/*
 * # AWS IAM Role module
 * Terraform module which creates SAF2.0 IAM Role in AWS
*/
#
# Filename    : modules/iam/examples/role_with_customer_managed_policy
# Date        : Dec 6, 2021
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : iam role creation with mutliple customer_managed_policy
#
locals {
  name               = var.name
  policy_name        = var.policy_name
  path               = var.path
  description        = var.description
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

data "aws_iam_policy_document" "resource" {
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["arn:aws:s3:::*"]
    effect    = "Allow"
  }
}

###########################################
# Role Creation with customer managed policy
###########################################
module "iam_policy" {
  source = "../../modules/iam_policy"

  name        = local.policy_name
  path        = local.path
  description = local.description
  policy      = [data.aws_iam_policy_document.resource.json]
  tags        = merge(module.tags.tags, local.optional_tags)
}

module "aws_iam_role" {
  source      = "../../"
  name        = local.name
  aws_service = local.aws_service
  #Customer Managed Policy
  policy_arns = [module.iam_policy.arn]
  tags        = merge(module.tags.tags, local.optional_tags)

  depends_on = [
    module.iam_policy
  ]

}

