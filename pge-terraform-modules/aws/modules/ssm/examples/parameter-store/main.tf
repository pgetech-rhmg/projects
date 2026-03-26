/*
 * # AWS SSM module
 * Terraform module which creates SAF2.0 parameters in SSM parameter-store in AWS
*/

# Filename    : modules/ssm/main.tf
# Date        : 13 September 2022
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : The example code creates SAF2.0 parameters in SSM parameter-store in AWS
#

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  aws_role           = var.aws_role
  kms_role           = var.kms_role
  optional_tags      = var.optional_tags
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

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.2"
#  name        = var.kms_name
#  description = var.kms_description
#  tags        = merge(module.tags.tags, local.optional_tags)
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
# }


module "ssm" {
  source = "../../"
  name   = var.name
  value  = var.value
  key_id = null # replace with module.kms_key.key_arn, after key creation
  tags   = merge(module.tags.tags, local.optional_tags)
}

