/*
 * # AWS S3 module
 * Terraform module which creates SAF2.0 S3 in AWS with default PGE policy and KMS.
*/
#
# Filename    : module/s3/examples/s3_pge_policy_custom_user/main.tf
# Date        : 20 June 2025
# Author      : pge
# Description : s3 bucekt creation module with custom user policy that combines with the compliance policy used for PGE S3 buckets.


locals {
  AppID                     = var.AppID
  Environment               = var.Environment
  DataClassification        = var.DataClassification
  CRIS                      = var.CRIS
  Notify                    = var.Notify
  Owner                     = var.Owner
  Compliance                = var.Compliance
  Order                     = var.Order
  grants                    = var.grants
  acl                       = var.acl
  object_lock_configuration = var.object_lock_configuration
  cors_rule_inputs          = var.cors_rule_inputs
  kms_role                  = var.kms_role
  aws_role                  = var.aws_role
  bucket_name               = random_pet.s3.id

}

data "aws_canonical_user_id" "current" {}


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

resource "random_pet" "s3" {
  length = 2
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
# Create S3 bucket with pge policy
#########################################
module "s3" {
  source                    = "../../"
  bucket_name               = random_pet.s3.id
  acl                       = local.acl
  kms_key_arn               = null # replace with module.kms_key.key_arn, after key creation
  grants                    = local.grants
  object_lock_configuration = local.object_lock_configuration
  versioning                = var.versioning
  tags                      = merge(module.tags.tags, { DRTier = "TIER 1 - Active / Active", Org = "Information Technology", BucketType = "s3web" })
  cors_rule_inputs          = local.cors_rule_inputs
  owner = {
    id = data.aws_canonical_user_id.current.id
  }
}


module "s3_custom_bucket_policy" {
  source      = "../../modules/s3_custom_bucket_policy"
  bucket_name = module.s3.s3.bucket
  bucket_id   = module.s3.s3.id
  policy      = templatefile("${path.module}/s3_bucket_custom_user_policy.json", { aws_role = local.aws_role, account_num = var.account_num, bucket_name = local.bucket_name })

}


