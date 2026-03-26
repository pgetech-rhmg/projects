/*
 * Resources for Malware Scanning in Forensics Account
 * Terraform module which creates SAF2.0 for Malware Scanning in Forensics Account
*/

# Filename    : aws/modules/ram/examples/ram-association-for-logically-air-gapped-vault/main.tf
# Date        : 3 Apr 2025
# Author      : Sethu Lakshmi (sul3@pge.com)
# Description : Manages Forensics Account Resources
#

locals {
  optional_tags = var.optional_tags
  name          = var.name
}

resource "random_string" "name" {
  length  = 5
  upper   = false
  special = false
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}


###############################################################
# AWS Lambda for Enabling GD Malware Scanning for S3 Resource
###############################################################
module "backup_restore_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.0"

  name = "AllowS3AWSBackupRestore"
  path = "/"
  policy = [jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:ReEncrypt"
        ]
        Resource = "arn:aws:kms:${var.aws_region}:654654458533:key/*"
      }
    ]
  })]

  tags = merge(module.tags.tags, var.optional_tags)
}

module "aws_backup_restore_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.0.9"

  name        = "CustomAWSBackupRestoreRole"
  aws_service = var.restore_iam_aws_service
  tags        = merge(module.tags.tags, var.optional_tags)
  policy_arns = concat(var.policy_arns_list, [module.backup_restore_policy.arn])

}

module "restore-testing-s3" {
  source = "../../modules/backup-restore-testing/"

  restore_plan_name       = var.restore_plan_name_s3
  algorithm               = var.algorithm
  include_vaults          = var.include_vaults
  recovery_point_types    = var.recovery_point_types
  schedule_expression     = var.schedule_expression
  tags                    = merge(module.tags.tags, local.optional_tags)
  resource_selection_name = var.resource_selection_name_s3
  resource_type           = var.resource_type_s3
  resource_role_arn       = module.aws_backup_restore_iam_role.arn
  resource_arns           = var.resource_arns
  validation_window_hours = var.validation_window_hours
}
