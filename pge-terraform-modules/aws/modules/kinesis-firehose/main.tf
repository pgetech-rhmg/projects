/*
* # AWS Kinesis firehose module
* Terraform module which creates kinesis firehose
*/
# Filename     : aws/modules/kinesis-firehose/main.tf 
# database     : 06 Sep 2022
# Author       : TCS
#  Description  : Terraform module for creation of kinesis firehose

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

#######################################################################
# Module : kinesis firehose
# Description : This terraform module creates kinesis firehose
#######################################################################

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

data "external" "validate_kms_elasticsearch_configuration_s3_configuration" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.elasticsearch_configuration.s3_configuration.kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

data "external" "validate_kms_extended_s3_configuration" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.extended_s3_configuration.kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

data "external" "validate_kms_s3_backup" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.extended_s3_configuration.s3_backup_kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

data "external" "validate_kms_redshift" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.redshift_configuration.s3_backup_kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

data "external" "validate_kms_redshift_s3_configuration" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.redshift_configuration.s3_configuration.kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

data "external" "validate_kms_splunk_s3_configuration" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.splunk_configuration.s3_configuration.kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

data "external" "validate_http_endpoint_s3_configuration" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.http_endpoint_configuration.s3_configuration.kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_delivery_stream" {

  name        = var.name
  destination = var.destination

  # kinesis source configuration executes once if end user requires kinesis stream as source
  dynamic "kinesis_source_configuration" {
    for_each = var.kinesis_source_server_side_encryption.kinesis_stream_arn != null && var.kinesis_source_server_side_encryption.role_arn != null ? [true] : []
    content {
      kinesis_stream_arn = var.kinesis_source_server_side_encryption.kinesis_stream_arn
      role_arn           = var.kinesis_source_server_side_encryption.role_arn
    }
  }

  # kinesis source configuration is used by end user than server side enryption block does not execute.
  # server side encryption is required if kinesis source configuration is not used and below block executes once
  dynamic "server_side_encryption" {
    for_each = var.enable_server_side_encryption && var.kinesis_source_server_side_encryption.kinesis_stream_arn == null ? [true] : []
    content {
      enabled = var.kinesis_source_server_side_encryption.kinesis_stream_arn == null
      #As per SAF rules only PGE managed keys are allowed 
      key_type = "CUSTOMER_MANAGED_CMK"
      key_arn  = var.kinesis_source_server_side_encryption.key_arn
    }
  }

  







  # extended_s3_configuration executes once if var.destination is 'extended_s3'
  dynamic "extended_s3_configuration" {
    for_each = var.destination == "extended_s3" ? [true] : []
    content {
      role_arn            = var.extended_s3_configuration.role_arn
      bucket_arn          = var.extended_s3_configuration.bucket_arn
      prefix              = var.extended_s3_configuration.prefix
      buffering_size      = var.extended_s3_configuration.buffer_size
      buffering_interval  = var.extended_s3_configuration.buffer_interval
      compression_format  = var.extended_s3_configuration.compression_format
      error_output_prefix = var.extended_s3_configuration.error_output_prefix
      kms_key_arn         = var.extended_s3_configuration.kms_key_arn

      cloudwatch_logging_options {
        # As per SAF rules cloudwatch logging has to be enabled
        enabled         = true
        log_group_name  = var.extended_s3_configuration.log_group_name
        log_stream_name = var.extended_s3_configuration.log_stream_name
      }


      dynamic "data_format_conversion_configuration" {
        # data_format_conversion_configuration executes once if enabled 
        for_each = var.extended_s3_configuration.data_format_conversion_enabled == true ? [true] : []
        content {
          input_format_configuration {
            deserializer {
              dynamic "hive_json_ser_de" {
                # as per aws documentation can choose either the Apache Hive JSON SerDe or the OpenX JSON SerDe
                for_each = var.extended_s3_configuration.deserializer == "hive_json_ser_de" ? [true] : []
                content {
                  timestamp_formats = var.extended_s3_configuration.hive_json_ser_de_timestamp_formats
                }
              }
              dynamic "open_x_json_ser_de" {
                # as per aws documentation can choose either the Apache Hive JSON SerDe or the OpenX JSON SerDe
                for_each = var.extended_s3_configuration.deserializer == "open_x_json_ser_de" ? [true] : []
                content {
                  case_insensitive                         = var.extended_s3_configuration.open_x_json_ser_de_case_insensitive
                  column_to_json_key_mappings              = var.extended_s3_configuration.open_x_json_ser_de_column_to_json_key_mappings
                  convert_dots_in_json_keys_to_underscores = var.extended_s3_configuration.open_x_json_ser_de_convert_dots_in_json_keys_to_underscores
                }
              }
            }
          }

          output_format_configuration {
            serializer {
              dynamic "orc_ser_de" {
                # as per aws documentation can choose either the ORC SerDe or the Parquet SerDe.
                for_each = var.extended_s3_configuration.serializer == "orc_ser_de" ? [true] : []
                content {
                  block_size_bytes                        = var.extended_s3_configuration.orc_ser_de_block_size_bytes
                  bloom_filter_columns                    = var.extended_s3_configuration.orc_ser_de_bloom_filter_columns
                  bloom_filter_false_positive_probability = var.extended_s3_configuration.orc_ser_de_bloom_filter_false_positive_probability
                  compression                             = var.extended_s3_configuration.orc_ser_de_compression
                  dictionary_key_threshold                = var.extended_s3_configuration.orc_ser_de_dictionary_key_threshold
                  enable_padding                          = var.extended_s3_configuration.orc_ser_de_enable_padding
                  format_version                          = var.extended_s3_configuration.orc_ser_de_format_version
                  padding_tolerance                       = var.extended_s3_configuration.orc_ser_de_padding_tolerance
                  row_index_stride                        = var.extended_s3_configuration.orc_ser_de_row_index_stride
                  stripe_size_bytes                       = var.extended_s3_configuration.orc_ser_de_stripe_size_bytes
                }
              }
              dynamic "parquet_ser_de" {
                # as per aws documentation can choose either the ORC SerDe or the Parquet SerDe.
                for_each = var.extended_s3_configuration.serializer == "parquet_ser_de" ? [true] : []
                content {
                  block_size_bytes              = var.extended_s3_configuration.parquet_ser_de_block_size_bytes
                  compression                   = var.extended_s3_configuration.parquet_ser_de_compression
                  enable_dictionary_compression = var.extended_s3_configuration.parquet_ser_de_enable_dictionary_compression
                  max_padding_bytes             = var.extended_s3_configuration.parquet_ser_de_max_padding_bytes
                  page_size_bytes               = var.extended_s3_configuration.parquet_ser_de_page_size_bytes
                  writer_version                = var.extended_s3_configuration.parquet_ser_de_writer_version
                }
              }
            }
          }

          schema_configuration {
            database_name = var.extended_s3_configuration.schema_configuration_database_name
            role_arn      = var.extended_s3_configuration.schema_configuration_role_arn
            table_name    = var.extended_s3_configuration.schema_configuration_table_name
            catalog_id    = var.extended_s3_configuration.schema_configuration_catalog_id
            region        = var.extended_s3_configuration.schema_configuration_region
            version_id    = var.extended_s3_configuration.schema_configuration_version_id
          }
          enabled = var.extended_s3_configuration.data_format_conversion_enabled
        }
      }

      dynamic "processing_configuration" {
        # processing_configuration blocks executes once if enabled
        for_each = var.extended_s3_configuration.processing_configuration.enabled == true ? [true] : []
        content {
          enabled = var.extended_s3_configuration.processing_configuration.enabled
          dynamic "processors" {
            # processors block loops over as many times user requires.
            for_each = var.extended_s3_configuration.processing_configuration.processors
            content {
              type = processors.value.type
              dynamic "parameters" {
                # parameters block loops over as many times user requires.
                for_each = processors.value.parameters
                content {
                  parameter_name  = parameters.value.parameter_name
                  parameter_value = parameters.value.parameter_value
                }
              }
            }
          }
        }
      }

      dynamic "dynamic_partitioning_configuration" {
        # dynamic_partitioning_configuration executes once if enabled 
        for_each = var.extended_s3_configuration.dynamic_partitioning_enabled == true ? [true] : []
        content {
          enabled        = var.extended_s3_configuration.dynamic_partitioning_enabled
          retry_duration = var.extended_s3_configuration.dynamic_partitioning_retry_duration
        }
      }

      s3_backup_mode = var.extended_s3_configuration.s3_backup_mode
      # s3_backup_configuration is required if s3_backup_mode is enabled 
      dynamic "s3_backup_configuration" {
        for_each = var.extended_s3_configuration.s3_backup_mode == "Enabled" ? [true] : []
        content {
          role_arn            = var.extended_s3_configuration.s3_backup_role_arn
          bucket_arn          = var.extended_s3_configuration.s3_backup_bucket_arn
          prefix              = var.extended_s3_configuration.s3_backup_prefix
          buffering_size      = var.extended_s3_configuration.s3_backup_buffer_size
          buffering_interval  = var.extended_s3_configuration.s3_backup_buffer_interval
          compression_format  = var.extended_s3_configuration.s3_backup_compression_format
          error_output_prefix = var.extended_s3_configuration.s3_backup_error_output_prefix
          kms_key_arn         = var.extended_s3_configuration.s3_backup_kms_key_arn

          cloudwatch_logging_options {
            # As per SAF rules cloudwatch logging has to be enabled
            enabled         = true
            log_group_name  = var.extended_s3_configuration.s3_backup_log_group_name
            log_stream_name = var.extended_s3_configuration.s3_backup_log_stream_name
          }
        }
      }
    }
  }

  # redshift_configuration block executes once if var.destination is 'redshift'
  dynamic "redshift_configuration" {
    for_each = var.destination == "redshift" ? [true] : []
    content {
      cluster_jdbcurl    = var.redshift_configuration.cluster_jdbcurl
      username           = var.redshift_configuration.username
      password           = var.redshift_configuration.password
      retry_duration     = var.redshift_configuration.retry_duration
      role_arn           = var.redshift_configuration.role_arn
      data_table_name    = var.redshift_configuration.data_table_name
      copy_options       = var.redshift_configuration.copy_options
      data_table_columns = var.redshift_configuration.data_table_columns

      s3_backup_mode = var.redshift_configuration.s3_backup_mode
      # s3_backup_configuration is required if s3_backup_mode is enabled and executes once
      dynamic "s3_backup_configuration" {
        for_each = var.redshift_configuration.s3_backup_mode == "Enabled" ? [true] : []
        content {
          role_arn            = var.redshift_configuration.s3_backup_role_arn
          bucket_arn          = var.redshift_configuration.s3_backup_bucket_arn
          prefix              = var.redshift_configuration.s3_backup_prefix
          buffering_size      = var.redshift_configuration.s3_backup_buffer_size
          buffering_interval  = var.redshift_configuration.s3_backup_buffer_interval
          compression_format  = var.redshift_configuration.s3_backup_compression_format
          error_output_prefix = var.redshift_configuration.s3_backup_error_output_prefix
          kms_key_arn         = var.redshift_configuration.s3_backup_kms_key_arn

          cloudwatch_logging_options {
            # As per SAF rules cloudwatch logging has to be enabled
            enabled         = true
            log_group_name  = var.redshift_configuration.s3_backup_log_group_name
            log_stream_name = var.redshift_configuration.s3_backup_log_stream_name
          }
        }
      }

      dynamic "s3_configuration" {
        for_each = var.destination == "redshift" ? [true] : []
        content {
          role_arn            = var.redshift_configuration.s3_configuration.role_arn
          bucket_arn          = var.redshift_configuration.s3_configuration.bucket_arn
          prefix              = var.redshift_configuration.s3_configuration.prefix
          buffering_size      = var.redshift_configuration.s3_configuration.buffer_size
          buffering_interval  = var.redshift_configuration.s3_configuration.buffer_interval
          compression_format  = var.redshift_configuration.s3_configuration.compression_format
          error_output_prefix = var.redshift_configuration.s3_configuration.error_output_prefix
          kms_key_arn         = var.redshift_configuration.s3_configuration.kms_key_arn

          cloudwatch_logging_options {
            # As per SAF rules cloudwatch logging has to be enabled
            enabled         = true
            log_group_name  = var.redshift_configuration.s3_configuration.log_group_name
            log_stream_name = var.redshift_configuration.s3_configuration.log_stream_name
          }
        }
      }


      cloudwatch_logging_options {
        # As per SAF rules cloudwatch logging has to be enabled
        enabled         = true
        log_group_name  = var.redshift_configuration.log_group_name
        log_stream_name = var.redshift_configuration.log_stream_name
      }

      dynamic "processing_configuration" {
        # processing_configuration blocks executes once if enabled
        for_each = var.redshift_configuration.processing_configuration.enabled == true ? [true] : []
        content {
          enabled = var.redshift_configuration.processing_configuration.enabled
          dynamic "processors" {
            # processors block loops over as many times user requires.
            for_each = var.redshift_configuration.processing_configuration.processors
            content {
              type = processors.value.type
              dynamic "parameters" {
                # parameters block loops over as many times user requires.
                for_each = processors.value.parameters
                content {
                  parameter_name  = parameters.value.parameter_name
                  parameter_value = parameters.value.parameter_value
                }
              }
            }
          }
        }
      }

    }
  }

  # elasticsearch_configuration block executes once if var.destination is 'elasticsearch'
  dynamic "elasticsearch_configuration" {
    for_each = var.destination == "elasticsearch" ? [true] : []
    content {
      buffering_interval = var.elasticsearch_configuration.buffering_interval
      buffering_size     = var.elasticsearch_configuration.buffering_size
      domain_arn         = var.elasticsearch_configuration.domain_arn
      cluster_endpoint   = var.elasticsearch_configuration.cluster_endpoint
      index_name         = var.elasticsearch_configuration.index_name
      retry_duration     = var.elasticsearch_configuration.retry_duration
      role_arn           = var.elasticsearch_configuration.role_arn
      s3_backup_mode     = var.elasticsearch_configuration.s3_backup_mode
      type_name          = var.elasticsearch_configuration.type_name

      cloudwatch_logging_options {
        # As per SAF rules cloudwatch logging has to be enabled
        enabled         = true
        log_group_name  = var.elasticsearch_configuration.log_group_name
        log_stream_name = var.elasticsearch_configuration.log_stream_name
      }

      dynamic "s3_configuration" {
        for_each = var.destination == "elasticsearch" ? [true] : []
        content {
          role_arn            = var.elasticsearch_configuration.s3_configuration.role_arn
          bucket_arn          = var.elasticsearch_configuration.s3_configuration.bucket_arn
          prefix              = var.elasticsearch_configuration.s3_configuration.prefix
          buffering_size      = var.elasticsearch_configuration.s3_configuration.buffer_size
          buffering_interval  = var.elasticsearch_configuration.s3_configuration.buffer_interval
          compression_format  = var.elasticsearch_configuration.s3_configuration.compression_format
          error_output_prefix = var.elasticsearch_configuration.s3_configuration.error_output_prefix
          kms_key_arn         = var.elasticsearch_configuration.s3_configuration.kms_key_arn

          cloudwatch_logging_options {
            # As per SAF rules cloudwatch logging has to be enabled
            enabled         = true
            log_group_name  = var.elasticsearch_configuration.s3_configuration.log_group_name
            log_stream_name = var.elasticsearch_configuration.s3_configuration.log_stream_name
          }
        }
      }

      dynamic "processing_configuration" {
        # processing_configuration blocks executes once if enabled
        for_each = var.elasticsearch_configuration.processing_configuration.enabled == true ? [true] : []
        content {
          enabled = var.elasticsearch_configuration.processing_configuration.enabled
          dynamic "processors" {
            # processors block loops over as many times user requires.
            for_each = var.elasticsearch_configuration.processing_configuration.processors
            content {
              type = processors.value.type
              dynamic "parameters" {
                # parameters block loops over as many times user requires.
                for_each = processors.value.parameters
                content {
                  parameter_name  = parameters.value.parameter_name
                  parameter_value = parameters.value.parameter_value
                }
              }
            }
          }
        }
      }

      vpc_config {
        subnet_ids         = var.elasticsearch_configuration.vpc_config_subnet_ids
        security_group_ids = var.elasticsearch_configuration.vpc_config_security_group_ids
        role_arn           = var.elasticsearch_configuration.vpc_config_role_arn
      }
    }
  }

  # splunk_configuration block executes once if var.destination is 'splunk'
  dynamic "splunk_configuration" {
    for_each = var.destination == "splunk" ? [true] : []
    content {
      hec_acknowledgment_timeout = var.splunk_configuration.hec_acknowledgment_timeout
      hec_endpoint               = var.splunk_configuration.hec_endpoint
      hec_endpoint_type          = var.splunk_configuration.hec_endpoint_type
      hec_token                  = var.splunk_configuration.hec_token
      s3_backup_mode             = var.splunk_configuration.s3_backup_mode
      retry_duration             = var.splunk_configuration.retry_duration

      cloudwatch_logging_options {
        # As per SAF rules cloudwatch logging has to be enabled
        enabled         = true
        log_group_name  = var.splunk_configuration.log_group_name
        log_stream_name = var.splunk_configuration.log_stream_name
      }

      dynamic "s3_configuration" {
        for_each = var.destination == "splunk" ? [true] : []
        content {
          role_arn            = var.splunk_configuration.s3_configuration.role_arn
          bucket_arn          = var.splunk_configuration.s3_configuration.bucket_arn
          prefix              = var.splunk_configuration.s3_configuration.prefix
          buffering_size      = var.splunk_configuration.s3_configuration.buffer_size
          buffering_interval  = var.splunk_configuration.s3_configuration.buffer_interval
          compression_format  = var.splunk_configuration.s3_configuration.compression_format
          error_output_prefix = var.splunk_configuration.s3_configuration.error_output_prefix
          kms_key_arn         = var.splunk_configuration.s3_configuration.kms_key_arn

          cloudwatch_logging_options {
            # As per SAF rules cloudwatch logging has to be enabled
            enabled         = true
            log_group_name  = var.splunk_configuration.s3_configuration.log_group_name
            log_stream_name = var.splunk_configuration.s3_configuration.log_stream_name
          }
        }
      }

      dynamic "processing_configuration" {
        # processing_configuration blocks executes once if enabled
        for_each = var.splunk_configuration.processing_configuration.enabled == true ? [true] : []
        content {
          enabled = var.splunk_configuration.processing_configuration.enabled
          dynamic "processors" {
            # processors block loops over as many times user requires.
            for_each = var.splunk_configuration.processing_configuration.processors
            content {
              type = processors.value.type
              dynamic "parameters" {
                # parameters block loops over as many times user requires.
                for_each = processors.value.parameters
                content {
                  parameter_name  = parameters.value.parameter_name
                  parameter_value = parameters.value.parameter_value
                }
              }
            }
          }
        }
      }

    }
  }

  # http_endpoint_configuration block executes once if var.destination is 'http_endpoint'
  dynamic "http_endpoint_configuration" {
    for_each = var.destination == "http_endpoint" ? [true] : []
    content {
      url                = var.http_endpoint_configuration.url
      name               = var.http_endpoint_configuration.name
      access_key         = var.http_endpoint_configuration.access_key
      role_arn           = var.http_endpoint_configuration.role_arn
      s3_backup_mode     = var.http_endpoint_configuration.s3_backup_mode
      buffering_size     = var.http_endpoint_configuration.buffering_size
      buffering_interval = var.http_endpoint_configuration.buffering_interval
      retry_duration     = var.http_endpoint_configuration.retry_duration

      cloudwatch_logging_options {
        # As per SAF rules cloudwatch logging has to be enabled
        enabled         = true
        log_group_name  = var.http_endpoint_configuration.log_group_name
        log_stream_name = var.http_endpoint_configuration.log_stream_name
      }

      dynamic "s3_configuration" {
        for_each = var.destination == "http_endpoint" ? [true] : []
        content {
          role_arn            = var.http_endpoint_configuration.s3_configuration.role_arn
          bucket_arn          = var.http_endpoint_configuration.s3_configuration.bucket_arn
          prefix              = var.http_endpoint_configuration.s3_configuration.prefix
          buffering_size      = var.http_endpoint_configuration.s3_configuration.buffer_size
          buffering_interval  = var.http_endpoint_configuration.s3_configuration.buffer_interval
          compression_format  = var.http_endpoint_configuration.s3_configuration.compression_format
          error_output_prefix = var.http_endpoint_configuration.s3_configuration.error_output_prefix
          kms_key_arn         = var.http_endpoint_configuration.s3_configuration.kms_key_arn

          cloudwatch_logging_options {
            # As per SAF rules cloudwatch logging has to be enabled
            enabled         = true
            log_group_name  = var.http_endpoint_configuration.s3_configuration.log_group_name
            log_stream_name = var.hhttp_endpoint_configuration.log_stream_name
          }
        }
      }

      dynamic "processing_configuration" {
        for_each = var.http_endpoint_configuration.processing_configuration.enabled == true ? [true] : []
        content {
          enabled = var.http_endpoint_configuration.processing_configuration.enabled
          dynamic "processors" {
            for_each = var.http_endpoint_configuration.processing_configuration.processors
            content {
              type = processors.value.type
              dynamic "parameters" {
                for_each = processors.value.parameters
                content {
                  parameter_name  = parameters.value.parameter_name
                  parameter_value = parameters.value.parameter_value
                }
              }
            }
          }
        }
      }

      request_configuration {
        content_encoding = var.http_endpoint_configuration.content_encoding
        dynamic "common_attributes" {
          for_each = var.http_endpoint_configuration.common_attributes
          content {
            name  = common_attributes.value.name
            value = common_attributes.value.value
          }
        }
      }
    }
  }

  tags = local.module_tags
}