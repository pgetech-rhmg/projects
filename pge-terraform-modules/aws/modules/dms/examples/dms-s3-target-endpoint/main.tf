/*
* # AWS DMS with S3 Target Endpoint Example
* Terraform module which creates SAF2.0 DMS resources with S3 target endpoint in AWS.
* This example shows how to configure DMS to migrate data to an S3 bucket
*/

#
# Filename    : modules/dms/examples/dms-s3-target-endpoint/main.tf
# Date        : 02 March 2026
# Author      : PGE
# Description : Example implementation of DMS with S3 target endpoint

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
  Order              = var.Order
}

# Required tags module
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

# KMS key for encryption (uncomment if encryption is required)
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.0"
#
#   name        = var.kms_name
#   description = var.kms_description
#   aws_role    = local.aws_role
#   kms_role    = local.kms_role
#   tags        = merge(module.tags.tags, local.optional_tags)
# }

# DMS Service Access Role for S3 using PGE IAM module
module "dms_s3_access_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = "${var.source_endpoint_id}-dms-s3-access-role"
  aws_service = ["dms.amazonaws.com"]
  tags        = merge(module.tags.tags, local.optional_tags)

  # Inline policy for S3 access
  inline_policy = [
    jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:PutObjectTagging"
          ]
          Resource = "${var.s3_target_bucket_arn}/*"
        },
        {
          Effect = "Allow"
          Action = [
            "s3:ListBucket"
          ]
          Resource = var.s3_target_bucket_arn
        }
      ]
    })
  ]
}

# Source endpoint (traditional database) and S3 Target Endpoint - using combined S3 module
data "aws_ssm_parameter" "dms_username" {
  name = var.ssm_parameter_dms_username
}

data "aws_ssm_parameter" "dms_password" {
  name = var.ssm_parameter_dms_password
}

module "dms_s3_endpoints" {
  source = "../../modules/dms_endpoint_s3"

  # Source endpoint configuration (database)
  source_endpoint_id                          = var.source_endpoint_id
  source_endpoint_engine_name                 = var.source_endpoint_engine_name
  source_endpoint_kms_key_arn                 = null # replace with module.kms_key.key_arn if using encryption
  source_endpoint_server_name                 = var.source_endpoint_server_name
  source_endpoint_database_name               = var.source_endpoint_database_name
  source_endpoint_ssl_mode                    = var.source_endpoint_ssl_mode
  source_endpoint_username                    = data.aws_ssm_parameter.dms_username.value
  source_endpoint_password                    = data.aws_ssm_parameter.dms_password.value
  source_endpoint_port                        = var.source_endpoint_port
  source_certificate_arn                      = var.source_certificate_arn
  source_endpoint_service_access_role         = var.source_endpoint_service_access_role
  source_endpoint_extra_connection_attributes = var.source_endpoint_extra_connection_attributes

  # S3 Target endpoint configuration
  endpoint_id             = var.s3_target_endpoint_id
  kms_key_arn             = null # replace with module.kms_key.key_arn if using encryption
  service_access_role_arn = module.dms_s3_access_role.arn

  # S3 Configuration
  s3_bucket_name   = var.s3_target_bucket_name
  s3_bucket_folder = var.s3_target_bucket_folder
  data_format      = var.s3_data_format
  compression_type = var.s3_compression_type

  # Date partitioning for better organization
  date_partition_enabled  = var.enable_date_partitioning
  date_partition_sequence = var.date_partition_sequence

  # CSV specific settings
  csv_delimiter            = var.csv_delimiter
  csv_row_delimiter        = var.csv_row_delimiter
  include_op_for_full_load = var.include_op_for_full_load
  add_column_name          = var.add_column_name

  # Encryption settings
  encryption_mode                   = var.s3_encryption_mode
  server_side_encryption_kms_key_id = var.s3_kms_key_id

  tags = merge(module.tags.tags, local.optional_tags)
}