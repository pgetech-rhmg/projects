/*
 * # AWS codebuild report User module example
*/
#
#  Filename    : aws/modules/codebuild/examples/codebuild_report/main.tf
#  Date        : 24 January 2022
#  Author      : TCS
#  Description : This terraform module creates a codebuild report


locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
  aws_role           = var.aws_role
  kms_role           = var.kms_role
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.0"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
}


################################################################################
# Supporting Resources
################################################################################

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "codebuild_report_group" {
  source                      = "../../modules/codebuild_report"
  codebuild_rg_name           = var.codebuild_rg_name
  codebuild_rg_type           = var.codebuild_rg_type
  codebuild_rg_delete_reports = var.codebuild_rg_delete_reports
  codebuild_rg_export_type    = var.codebuild_rg_export_type
  codebuild_rg_bucket         = module.s3.id
  codebuild_rg_kms            = module.kms_key.key_arn
  codebuild_rg_path           = var.codebuild_rg_path
  codebuild_resource_policy   = templatefile("${path.module}/${var.policy_file_name}", { account_num = data.aws_caller_identity.current.account_id, partition = data.aws_partition.current.partition, aws_region = data.aws_region.current.name, codebuild_rg_name = var.codebuild_rg_name })
  tags                        = merge(module.tags.tags, local.optional_tags)
}

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.0"

  bucket_name = var.bucket_name
  kms_key_arn = module.kms_key.key_arn
  tags        = merge(module.tags.tags, local.optional_tags)
}

module "kms_key" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.0"

  name        = var.kms_name
  description = var.kms_description
  tags        = merge(module.tags.tags, local.optional_tags)
  aws_role    = local.aws_role
  kms_role    = local.kms_role
}