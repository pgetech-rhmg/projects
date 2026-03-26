/*
 * # AWS sagemaker feature group module.
 * Terraform module which creates SAF2.0 Sagemaker feature group in AWS.
*/
#  Filename    : aws/modules/sagemaker/module/feature_group/main.tf
#  Date        : 09 Sep 2022
#  Author      : TCS
#  Description : Sagemaker feature group Creation
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : Creation of sagemaker feature group 
# Description : This terraform module creates a sagemaker feature group.

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

resource "aws_sagemaker_feature_group" "feature_group" {
  feature_group_name             = var.feature_group_name
  record_identifier_feature_name = var.feature_name.record_identifier_feature_name
  event_time_feature_name        = var.feature_name.event_time_feature_name
  role_arn                       = var.role_arn
  description                    = coalesce(var.description, format("%s - Managed by Terraform", var.feature_group_name))

  #The'feature definition 'block, can iterate multiple times if multiple values are passed for the variable 'feature definition'. 
  dynamic "feature_definition" {
    for_each = var.feature_definition
    content {
      feature_name = feature_definition.value.feature_name
      feature_type = feature_definition.value.feature_type
    }
  }

  #The 'offline_store_config' dynamic block is optional and execute only once. Below optional block will run only if
  #value of 'offline_store_config' is provided. The variable 'offline_store_config' is a map
  #so the end user can pass the value in key-value pairs from the example.
  dynamic "offline_store_config" {
    for_each = var.offline_store_config != null ? [var.offline_store_config] : []
    content {
      disable_glue_table_creation = lookup(offline_store_config.value, "disable_glue_table_creation", null)
      #The 'data_storage_config' block, can iterate only once when the end user pass value for the variable 'offline_store_config'.
      dynamic "s3_storage_config" {
        for_each = [offline_store_config.value.s3_storage_config]
        content {
          kms_key_id = lookup(s3_storage_config.value, "kms_key_id", null)
          s3_uri     = s3_storage_config.value.s3_uri
        }
      }
      #The 'data_catalog_config' optional block, can iterate only once when the end user pass value for the variable 'offline_store_config'.
      dynamic "data_catalog_config" {
        for_each = lookup(offline_store_config.value, "data_catalog_config", {}) != {} ? [lookup(offline_store_config.value, "data_catalog_config", {})] : []
        content {
          catalog    = lookup(data_catalog_config.value, "catalog", null)
          database   = lookup(data_catalog_config.value, "database", null)
          table_name = lookup(data_catalog_config.value, "table_name", null)
        }
      }
    }
  }

  #The 'online_store_config' dynamic block is optional and execute only once. Below optional block will run only if
  #value of 'online_store_config' is provided. The variable 'online_store_config' is a map
  #so the end user can pass the value in key-value pairs from the example.
  dynamic "online_store_config" {
    for_each = var.online_store_config != null ? [var.online_store_config] : []
    content {
      enable_online_store = lookup(online_store_config.value, "enable_online_store", null)
      #The 'security_config' block, can iterate only once when the end user pass value for the variable 'online_store_config'.
      dynamic "security_config" {
        for_each = [online_store_config.value.security_config]
        content {
          kms_key_id = lookup(security_config.value, "kms_key_id", null)
        }
      }
    }
  }
  tags = local.module_tags

}