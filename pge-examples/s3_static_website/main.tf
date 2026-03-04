/*
 * # AWS S3 module
 * Terraform module example which creates SAF2.0 S3 static website in AWS.
*/
#
# Filename    : module/s3/examples/s3_static_website/main.tf
# Date        : 25 April 2022
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : s3 creation main

locals {
  custom_bucket_name = var.custom_bucket_name
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  account_num        = var.account_num
  aws_role           = var.aws_role
  kms_role           = var.kms_role
  website            = var.website
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
# Create S3 bucket for static website use
#########################################
module "s3" {
  source      = "../../"
  bucket_name = local.custom_bucket_name
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  policy      = templatefile("${path.module}/s3_bucket_user_policy.json", { aws_role = local.aws_role, account_num = local.account_num, bucket_name = local.custom_bucket_name })
  tags        = merge(module.tags.tags, { DRTier = "TIER 1 - Active / Active", Org = "Information Technology" })
}

module "s3_static_website" {
  source      = "../../modules/s3_static_website"
  bucket_name = module.s3.id
  website     = local.website
  depends_on  = [module.s3]
}




