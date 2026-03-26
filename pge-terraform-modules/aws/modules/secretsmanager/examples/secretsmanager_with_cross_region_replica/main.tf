#
# Filename    : modules/secretsmanager/examples/secretsmanager_with_cross_region_replica/main.tf
# Date        : 20 January 2021
# Author      : TCS
# Description : secretsmanager creation main

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

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.2"
#  name        = var.kms_name
#  description = var.kms_description
#  multi_region = true
#  tags        = merge(module.tags.tags, local.optional_tags)
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
# }

#########################################
# Create secretsmanager
#########################################
module "secretsmanager" {
  source                     = "../../"
  secretsmanager_name        = var.secretsmanager_name
  secretsmanager_description = var.secretsmanager_description
  kms_key_id                 = null                        # replace with module.kms_key.key_arn, after key creation
  recovery_window_in_days    = var.recovery_window_in_days #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
  replica_kms_key_id         = null                        # replace with module.kms_key.key_arn, after key creation    #Use replica kms key.
  replica_region             = var.replica_region
  tags                       = merge(module.tags.tags, local.optional_tags)
}



