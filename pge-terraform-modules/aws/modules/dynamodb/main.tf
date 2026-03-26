/*
 * # AWS DynamoDb Table module.
 * Terraform module which creates SAF2.0 Dynamodb tables in AWS.
 * Dynamodb-table with global-replica cannot be created with "table_billing_mode" "PROVISIONED". 
 * This is a known issue and is a bug with the aws-provider and reported in the below github link: 
 * https://github.com/hashicorp/terraform-provider-aws/issues/13097
 */

#
#  Filename    : aws/modules/dynamodb/main.tf
#  Date        : 29 March 2022
#  Author      : TCS
#  Description : dynamodb with table
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

# Module      : dynamodb with resource table
# Description : This terraform module creates a dynamodb with resource table.

locals {
  namespace           = "ccoe-tf-developers"
  replica_region_name = "us-east-1"
}

data "external" "validate_replica_kms_key_arn_us_east_1" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.create_replica == true && var.replica_kms_key_arn_us_east_1 == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

data "external" "validate_server_side_encryption_kms_key_arn" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.server_side_encryption_kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



resource "aws_dynamodb_table" "dynamodb_table" {
  name                   = var.table_name
  billing_mode           = var.table_billing_mode
  hash_key               = var.hash_key
  range_key              = var.range_key
  read_capacity          = var.read_capacity
  write_capacity         = var.write_capacity
  stream_enabled         = var.stream_enabled
  stream_view_type       = var.stream_view_type
  restore_source_name    = var.restore_source_name
  restore_to_latest_time = var.restore_to_latest_time
  restore_date_time      = var.restore_date_time
  table_class            = var.table_class

  dynamic "attribute" {
    for_each = var.hash_range_key_attributes

    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "ttl" {
    for_each = var.ttl_enabled == true ? [true] : []
    content {
      enabled        = var.ttl_enabled
      attribute_name = var.ttl_attribute_name
    }
  }

  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes

    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", null)
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes

    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      projection_type    = global_secondary_index.value.projection_type
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      read_capacity      = lookup(global_secondary_index.value, "read_capacity", null)
      write_capacity     = lookup(global_secondary_index.value, "write_capacity", null)
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
    }
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.server_side_encryption_kms_key_arn
  }

  tags = local.module_tags

  timeouts {
    create = var.timeouts_create
    delete = var.timeouts_delete
    update = var.timeouts_update
  }

  # Customer Managed CMK's on DynamoDb Global Table replicas is not supported while using the 'dynamodb_global_table' module.
  # Reference of the github links with the issue:
  # https://github.com/hashicorp/terraform-provider-aws/issues/16358
  # https://github.com/hashicorp/terraform-provider-aws/pull/18373
  # Hence replica configuration block of dynamodb_table module to be used for Dynamodb Global Table v2.

  # Creates replica in us-east-1' region. 

  dynamic "replica" {
    for_each = var.create_replica ? [true] : []
    content {
      region_name = local.replica_region_name
      kms_key_arn = var.replica_kms_key_arn_us_east_1
    }
  }


}
