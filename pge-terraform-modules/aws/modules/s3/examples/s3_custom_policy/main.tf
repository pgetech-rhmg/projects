/*
 * # AWS S3 module
 * Terraform module example which creates SAF2.0 S3 in AWS with custom bucket policy
*/
#
# Filename    : module/s3/examples/s3_custom_policy/main.tf
# Date        : 27 December 2021
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : s3 creation main with custom bucket policy
# Updated By  : Sara Ahmad (s7aw@pge.com)



locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  account_num        = var.account_num
  kms_role           = var.kms_role
  aws_role           = var.aws_role
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

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.1"
#  name        = var.kms_name
#  description = var.kms_description
#  tags        = module.tags.tags
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
# }


#########################################
# Create S3 bucket with user defined policy
#########################################
module "s3" {
  source                   = "../../"
  bucket_name              = var.bucket_name
  kms_key_arn              = null # replace with module.kms_key.key_arn, after key creation
  versioning               = var.versioning
  policy                   = templatefile("${path.module}/s3_bucket_user_policy.json", { aws_role = local.aws_role, account_num = local.account_num, bucket_name = var.bucket_name })
  tags                     = merge(module.tags.tags, { DRTier = "TIER 1 - Active / Active", Org = "Information Technology" })
  intelligent_tiering_name = var.intelligent_tiering_name
  deeparchive_days         = var.deeparchive_days
  archive_days             = var.archive_days
}




