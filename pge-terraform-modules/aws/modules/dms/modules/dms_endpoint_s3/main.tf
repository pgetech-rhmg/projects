/*
 * # AWS DMS S3 Target Endpoint module.
 * Terraform module which creates SAF2.0 DMS S3 Target Endpoint in AWS.
*/

#
#  Filename    : aws/modules/dms/modules/dms_endpoint_s3/main.tf
#  Date        : 02 March 2026
#  Author      : PGE
#  Description : DMS S3 Target Endpoint Creation for migrating data to S3 buckets.
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.0"
    }
  }
}

# Module      : DMS S3 Target Endpoint Creation
# Description : This terraform module creates a DMS target endpoint for S3 buckets.

locals {
  namespace = "ccoe-tf-developers"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

# KMS validation for data classification - source endpoint
data "external" "validate_kms_source_endpoint_kms_key_arn" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.source_endpoint_kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

# KMS validation for data classification - S3 target endpoint
data "external" "validate_kms_endpoint_kms_key_arn" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

# DMS Source Endpoint (Database)
resource "aws_dms_endpoint" "dms_source_endpoint" {
  endpoint_type = "source"
  endpoint_id   = var.source_endpoint_id
  engine_name   = var.source_endpoint_engine_name
  kms_key_arn   = var.source_endpoint_kms_key_arn

  username                    = var.source_endpoint_username
  password                    = var.source_endpoint_password
  port                        = var.source_endpoint_port
  ssl_mode                    = var.source_endpoint_ssl_mode
  server_name                 = var.source_endpoint_server_name
  certificate_arn             = var.source_certificate_arn
  database_name               = var.source_endpoint_database_name
  service_access_role         = var.source_endpoint_service_access_role
  extra_connection_attributes = var.source_endpoint_extra_connection_attributes
  tags                        = local.module_tags
}

# DMS S3 Target Endpoint
resource "aws_dms_s3_endpoint" "dms_s3_target_endpoint" {
  endpoint_type           = "target"
  endpoint_id             = var.endpoint_id
  service_access_role_arn = var.service_access_role_arn

  # S3 Configuration
  bucket_name                       = var.s3_bucket_name
  bucket_folder                     = var.s3_bucket_folder
  compression_type                  = var.compression_type
  csv_delimiter                     = var.csv_delimiter
  csv_row_delimiter                 = var.csv_row_delimiter
  data_format                       = var.data_format
  date_partition_enabled            = var.date_partition_enabled
  date_partition_sequence           = var.date_partition_sequence
  include_op_for_full_load          = var.include_op_for_full_load
  cdc_inserts_only                  = var.cdc_inserts_only
  parquet_timestamp_in_millisecond  = var.parquet_timestamp_in_millisecond
  parquet_version                   = var.parquet_version
  preserve_transactions             = var.preserve_transactions
  server_side_encryption_kms_key_id = var.server_side_encryption_kms_key_id
  encryption_mode                   = var.encryption_mode
  external_table_definition         = var.external_table_definition
  ignore_header_rows                = var.ignore_header_rows
  max_file_size                     = var.max_file_size
  rfc_4180                          = var.rfc_4180
  add_column_name                   = var.add_column_name

  # KMS and SSL configuration
  kms_key_arn = var.kms_key_arn

  tags = local.module_tags
}