/*
 * # AWS KMS  module
 * Terraform module which creates SAF2.0 CMK in AWS
*/
#
# Filename    : modules/kms/examples/kms_customized_policy
# Date        : Nov 22, 2021
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : kms module creation 
#

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  name               = var.name
  description        = var.description
  aws_role           = var.aws_role
  kms_role           = var.kms_role
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


module "kms_key" {
  source      = "../../"
  description = local.description
  name        = local.name
  policy      = file("${path.module}/${var.template_file_name}")
  tags        = merge(module.tags.tags, local.optional_tags)
  aws_role    = local.aws_role
  kms_role    = local.kms_role
}

