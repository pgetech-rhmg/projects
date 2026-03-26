/*
 * # AWS ECR  module
 * Terraform module which creates SAF2.0 ECR in AWS
*/
#
# Filename    : aws/modules/ecr/examples/ecr_custom_policy/main.tf
# Date        : 17 february 2022
# Author      : TCS
# Description : ECR usage with custom policy

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  aws_role           = var.aws_role
  optional_tags      = var.optional_tags
  kms_role           = var.kms_role
  Order              = var.Order
}


# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key
/* module "kms_key" {
  source      = "app.terraform.io/pgetech/kms/aws"
  version     = "0.1.2"
  name        = var.kms_name
  description = var.kms_description
  tags        = merge(module.tags.tags, local.optional_tags)
  aws_role    = local.aws_role
  kms_role    = local.kms_role
} */

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
# Create Elastic Container Registry
#########################################
module "ecr" {
  source   = "../../"
  ecr_name = var.ecr_name
  kms_key  = null # replace with module.kms_key.key_arn, after key creation
  policy   = file("${path.module}/${var.custom_policy_file}")
  tags     = merge(module.tags.tags, local.optional_tags)
}

