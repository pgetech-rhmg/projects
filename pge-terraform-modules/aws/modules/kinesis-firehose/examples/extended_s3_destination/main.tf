/*
 * # AWS Kinesis firehose  User module example
*/
#
#  Filename    : aws/modules/kinesis-firehose/examples/extended_s3_destination/main.tf
#  Date        : 13 Sep 2022
#  Author      : TCS
#  Description : The terraform module creates a kinesis firehose 

locals {
  common_name = "${var.name}-${random_string.name.result}"
  glue_name   = "${var.name}_${random_string.name.result}"
  iam_policy = templatefile(
    "${path.module}/kinesis_firehose_iam_policy.json",
    {
      account_num = var.account_num,
      aws_region  = var.aws_region
  })
}


# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms klkey
module "kms_key" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.2"

  name     = local.common_name
  aws_role = var.aws_role
  kms_role = var.kms_role
  tags     = merge(module.tags.tags, var.optional_tags)
}

# The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 5
  special = false
  upper   = false
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



###################################################################################
# Kinesis firehose - extended s3 destination
###################################################################################

module "extended_s3_firehose" {
  source = "../../"

  name        = local.common_name
  destination = "extended_s3"
  enable_server_side_encryption = var.enable_server_side_encryption

  kinesis_source_server_side_encryption = {
    kinesis_stream_arn = module.kinesis_stream.arn
    role_arn           = module.firehose_aws_iam_role.arn
    key_arn            = var.server_side_encryption_key_arn
  }

  extended_s3_configuration = {
    role_arn    = module.firehose_aws_iam_role.arn
    bucket_arn  = module.s3.arn
    kms_key_arn = module.kms_key.key_arn

    prefix              = var.prefix
    buffer_size         = var.buffer_size
    buffer_interval     = var.buffer_interval
    compression_format  = var.compression_format
    error_output_prefix = var.error_output_prefix
    log_group_name      = module.log_group.cloudwatch_log_group_name
    log_stream_name     = var.log_stream_name

    s3_backup_mode                = var.s3_backup_mode
    s3_backup_role_arn            = module.firehose_aws_iam_role.arn
    s3_backup_bucket_arn          = module.s3.arn
    s3_backup_kms_key_arn         = null # replace with module.kms_key.key_arn, after key creation
    s3_backup_prefix              = var.s3_backup_prefix
    s3_backup_buffer_size         = var.s3_backup_buffer_size
    s3_backup_buffer_interval     = var.s3_backup_buffer_interval
    s3_backup_compression_format  = var.s3_backup_compression_format
    s3_backup_error_output_prefix = var.s3_backup_error_output_prefix
    s3_backup_log_group_name      = module.log_group.cloudwatch_log_group_name
    s3_backup_log_stream_name     = var.s3_backup_log_stream_name

    processing_configuration = {
      enabled = var.processing_configuration_enabled
      processors = [
        {
          type = var.processing_configuration_processors_type
          parameters = [{
            parameter_name  = var.processing_configuration_processors_parameter_name
            parameter_value = "${module.lambda_function.lambda_arn}:$LATEST"
          }]
        }
      ]
    }

    data_format_conversion_enabled = var.data_format_conversion_enabled

    deserializer                                                = var.deserializer
    hive_json_ser_de_timestamp_formats                          = var.hive_json_ser_de_timestamp_formats
    open_x_json_ser_de_case_insensitive                         = var.open_x_json_ser_de_case_insensitive
    open_x_json_ser_de_column_to_json_key_mappings              = var.open_x_json_ser_de_column_to_json_key_mappings
    open_x_json_ser_de_convert_dots_in_json_keys_to_underscores = var.open_x_json_ser_de_convert_dots_in_json_keys_to_underscores

    serializer                                         = var.serializer
    orc_ser_de_block_size_bytes                        = var.orc_ser_de_block_size_bytes
    orc_ser_de_bloom_filter_columns                    = var.orc_ser_de_bloom_filter_columns
    orc_ser_de_bloom_filter_false_positive_probability = var.orc_ser_de_bloom_filter_false_positive_probability
    orc_ser_de_compression                             = var.orc_ser_de_compression
    orc_ser_de_dictionary_key_threshold                = var.orc_ser_de_dictionary_key_threshold
    orc_ser_de_enable_padding                          = var.orc_ser_de_enable_padding
    orc_ser_de_format_version                          = var.orc_ser_de_format_version
    orc_ser_de_padding_tolerance                       = var.orc_ser_de_padding_tolerance
    orc_ser_de_row_index_stride                        = var.orc_ser_de_row_index_stride
    orc_ser_de_stripe_size_bytes                       = var.orc_ser_de_stripe_size_bytes
    parquet_ser_de_block_size_bytes                    = var.parquet_ser_de_block_size_bytes
    parquet_ser_de_compression                         = var.parquet_ser_de_compression
    parquet_ser_de_enable_dictionary_compression       = var.parquet_ser_de_enable_dictionary_compression
    parquet_ser_de_max_padding_bytes                   = var.parquet_ser_de_max_padding_bytes
    parquet_ser_de_page_size_bytes                     = var.parquet_ser_de_page_size_bytes
    parquet_ser_de_writer_version                      = var.parquet_ser_de_writer_version

    schema_configuration_database_name = null #local.glue_name
    schema_configuration_role_arn      = null #module.firehose_aws_iam_role.arn
    schema_configuration_table_name    = null #local.glue_name
    schema_configuration_catalog_id    = null #var.account_num
    schema_configuration_region        = null #var.aws_region
    schema_configuration_version_id    = null #var.schema_configuration_version_id

    dynamic_partitioning_enabled        = var.dynamic_partitioning_enabled
    dynamic_partitioning_retry_duration = var.dynamic_partitioning_retry_duration
  }

  tags = merge(module.tags.tags, var.optional_tags)
}

module "firehose_iam_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"

  name   = local.common_name
  path   = var.path
  policy = [local.iam_policy]
  tags   = merge(module.tags.tags, var.optional_tags)
}

module "firehose_aws_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = local.common_name
  aws_service = var.aws_service
  # Customer Managed Policy
  policy_arns = [module.firehose_iam_policy.arn]
  tags        = merge(module.tags.tags, var.optional_tags)

  depends_on = [
    module.firehose_iam_policy
  ]

}

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = local.common_name
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  policy      = data.template_file.s3_custom_bucket_policy.rendered
  tags        = merge(module.tags.tags, var.optional_tags)
}

data "template_file" "s3_custom_bucket_policy" {
  template = file("${path.module}/s3_bucket_user_policy.json")
  vars = { bucket_name = local.common_name,
    account_num = var.account_num
  }
}


module "log_group" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.1.3"

  name_prefix = local.common_name
  tags        = merge(module.tags.tags, var.optional_tags)
}

#  log stream module feature is not available in cloudwatch module, hence using resource to cretae log stream
resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = var.log_stream_name
  log_group_name = module.log_group.cloudwatch_log_group_name
}

module "kinesis_stream" {
  source  = "app.terraform.io/pgetech/kinesis-datastream/aws"
  version = "0.1.1"

  name = local.common_name

  stream_mode = {
    shard_count         = var.stream_mode.shard_count
    stream_mode_details = var.stream_mode.stream_mode_details
  }
  shard_level_metrics = var.shard_level_metrics
  kms_key_id          = null # replace with module.kms_key.key_arn, after key creation
  tags                = merge(module.tags.tags, var.optional_tags)
}

########################################################
# Glue database and table 
########################################################

module "catalog_database" {
  source  = "app.terraform.io/pgetech/glue/aws//modules/catalog_database"
  version = "0.1.1"

  # Here random_string resource is not used, since the variable validation doesnot work while using random_string.
  name                            = local.glue_name
  create_table_default_permission = var.create_table_default_permission
}

module "catalog_table" {
  source  = "app.terraform.io/pgetech/glue/aws//modules/catalog_table"
  version = "0.1.1"

  name = local.glue_name

  #name of the catalog_database
  database_name      = local.glue_name
  catalog_id         = var.account_num
  table_type         = var.table_type
  parameters         = var.parameters
  partition_keys     = var.partition_keys
  storage_descriptor = var.storage_descriptor
  depends_on = [
    module.catalog_database
  ]
}

##########################
# Lambda module
##########################

data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.subnet_id1_name
}

module "lambda_function" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.3"

  function_name = var.function_name
  role          = module.aws_lambda_iam_role.arn
  description   = var.description
  runtime       = var.runtime
  source_code = {
    source_dir = "${path.module}/${var.local_zip_source_directory}"
  }
  tags                          = merge(module.tags.tags, var.optional_tags)
  vpc_config_security_group_ids = [module.security_group_lambda.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  handler                       = var.handler
}

module "security_group_lambda" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = var.lambda_sg_name
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.lambda_cidr_ingress_rules
  cidr_egress_rules  = var.lambda_cidr_egress_rules
  tags               = merge(module.tags.tags, var.optional_tags)
}

module "aws_lambda_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.iam_name
  aws_service = var.iam_aws_service
  tags        = merge(module.tags.tags, var.optional_tags)

  #AWS_Managed_Policy
  policy_arns = var.iam_policy_arns
}