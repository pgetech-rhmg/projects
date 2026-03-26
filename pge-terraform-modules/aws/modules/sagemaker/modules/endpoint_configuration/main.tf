/*
* # AWS sagemaker endpoint_configuration module
* # Terraform module which creates Sagemaker endpoint_configuration
*/
#
# Filename     : aws/modules/sagemaker/modules/endpoint_configuration/main.tf
# Date         : Sept 7 2022 
# Author       : TCS
# Description  : Terraform sub-module for creation of endpoint_configuration in sagemaker
#

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
}

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

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassification type; exit 1"]
}

resource "aws_sagemaker_endpoint_configuration" "ec" {
  name        = var.name
  kms_key_arn = var.kms_key_id
  production_variants {
    initial_instance_count = var.initial_instance_count
    instance_type          = var.instance_type
    accelerator_type       = var.accelerator_type
    initial_variant_weight = var.initial_variant_weight
    model_name             = var.model_name
    variant_name           = var.variant_name
    dynamic "serverless_config" {
      # serverless_config is optional so this block will execute only when user provides the reqired input until it will be disabled  
      for_each = var.serverless_config != {} ? [var.serverless_config] : []
      content {
        max_concurrency   = serverless_config.value["max_concurrency"]
        memory_size_in_mb = serverless_config.value["memory_size_in_mb"]
      }
    }
  }
  # async_inference_config has nested blocks of client_config and output_config. For output_config except required rest of the arguments are made dynamic user can provide the value and condition looks for the value and executes the block.
  dynamic "async_inference_config" {
    for_each = var.async_inference_config != null ? [var.async_inference_config] : []
    content {
      dynamic "client_config" {
        for_each = lookup(async_inference_config.value, "client_config", {}) != {} ? [lookup(async_inference_config.value, "client_config", {})] : [] #lookup(async_inference_config.value, "client_config", {})
        content {
          max_concurrent_invocations_per_instance = lookup(client_config.value, "max_concurrent_invocations_per_instance", null)
        }
      }
      dynamic "output_config" {
        for_each = async_inference_config.value.output_config != {} ? [async_inference_config.value.output_config] : []
        content {
          s3_output_path = output_config.value["s3_output_path"]
          kms_key_id     = lookup(output_config.value, "kms_key_id", null)
          dynamic "notification_config" {
            for_each = lookup(output_config.value, "notification_config", {}) != {} ? [lookup(output_config.value, "notification_config", {})] : []
            content {
              error_topic   = lookup(notification_config.value, "error_topic", null)
              success_topic = lookup(notification_config.value, "success_topic", null)
            }
          }
        }
      }
    }
  }
  #  data_capture_config is an optional nested block so when parameters are passed the condition will look for the value and executes the block.
  dynamic "data_capture_config" {
    for_each = var.data_capture_config != null ? [var.data_capture_config] : []
    content {
      initial_sampling_percentage = data_capture_config.value["initial_sampling_percentage"]
      destination_s3_uri          = data_capture_config.value["destination_s3_uri"]
      kms_key_id                  = lookup(data_capture_config.value, "kms_key_id", null)
      enable_capture              = lookup(data_capture_config.value, "enable_capture", false)
      dynamic "capture_content_type_header" {
        for_each = lookup(data_capture_config.value, "capture_content_type_header", {}) != {} ? [lookup(data_capture_config.value, "capture_content_type_header", {})] : []
        content {
          csv_content_types  = lookup(capture_content_type_header.value, "csv_content_types", [])
          json_content_types = lookup(capture_content_type_header.value, "json_content_types", [])
        }
      }
      dynamic "capture_options" {
        for_each = data_capture_config.value.capture_options != {} ? [data_capture_config.value.capture_options] : []
        content {
          capture_mode = capture_options.value["capture_mode"]
        }
      }
    }
  }

  tags = local.module_tags
}