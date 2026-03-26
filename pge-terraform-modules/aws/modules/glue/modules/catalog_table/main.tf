/*
 * # AWS Glue Catalog_table module.
 * Terraform module which creates SAF2.0 Glue Catalog_table in AWS.
*/

#
#  Filename    : aws/modules/glue/module/catalog_table/main.tf
#  Date        : 17 August 2022
#  Author      : TCS
#  Description : Glue Catalog_table Creation
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

resource "aws_glue_catalog_table" "glue_catalog_table" {

  name          = var.name
  database_name = var.database_name

  catalog_id         = var.catalog_id
  description        = coalesce(var.description, format("%s catalog table - Managed by Terraform", var.name))
  owner              = var.owner
  retention          = var.retention
  table_type         = var.table_type
  view_expanded_text = var.view_expanded_text
  view_original_text = var.view_original_text
  parameters         = var.parameters

  dynamic "partition_index" {
    for_each = var.partition_index
    content {
      index_name = partition_index.value.index_name
      keys       = partition_index.value.keys
    }
  }

  dynamic "partition_keys" {
    for_each = var.partition_keys
    content {
      name    = partition_keys.value.name
      comment = lookup(partition_keys.value, "comment", null)
      type    = lookup(partition_keys.value, "type", null)
    }
  }

  dynamic "storage_descriptor" {
    for_each = var.storage_descriptor
    content {
      bucket_columns            = lookup(storage_descriptor.value, "bucket_columns", null)
      compressed                = lookup(storage_descriptor.value, "compressed", null)
      input_format              = lookup(storage_descriptor.value, "input_format", null)
      location                  = lookup(storage_descriptor.value, "location", null)
      number_of_buckets         = lookup(storage_descriptor.value, "number_of_buckets", null)
      output_format             = lookup(storage_descriptor.value, "output_format", null)
      parameters                = lookup(storage_descriptor.value, "parameters", {})
      stored_as_sub_directories = lookup(storage_descriptor.value, "stored_as_sub_directories", null)

      dynamic "columns" {
        for_each = lookup(storage_descriptor.value, "columns", {})
        content {
          name       = columns.value.name
          type       = columns.value.type
          comment    = lookup(columns.value, "comment", null)
          parameters = lookup(columns.value, "parameters", null)
        }
      }

      dynamic "schema_reference" {
        for_each = lookup(storage_descriptor.value, "schema_reference", {})
        content {
          schema_version_number = schema_reference.value.schema_version_number
          schema_version_id     = lookup(schema_reference.value, "schema_version_id", null)

          dynamic "schema_id" {
            for_each = lookup(schema_reference.value, "schema_id", {})
            content {
              registry_name = lookup(schema_id.value, "registry_name", null)
              schema_arn    = lookup(schema_id.value, "schema_arn", null)
              schema_name   = lookup(schema_id.value, "schema_name", null)
            }
          }
        }
      }

      dynamic "ser_de_info" {
        for_each = lookup(storage_descriptor.value, "ser_de_info", {})
        content {
          name                  = lookup(ser_de_info.value, "name", null)
          serialization_library = lookup(ser_de_info.value, "serialization_library", null)
          parameters            = lookup(ser_de_info.value, "parameters", null)
        }
      }

      dynamic "sort_columns" {
        for_each = lookup(storage_descriptor.value, "sort_columns", {})
        content {
          sort_order = sort_columns.value.sort_order
          column     = sort_columns.value.column
        }
      }

      dynamic "skewed_info" {
        for_each = lookup(storage_descriptor.value, "skewed_info", {})
        content {
          skewed_column_names               = lookup(skewed_info.value, "skewed_column_names", null)
          skewed_column_value_location_maps = lookup(skewed_info.value, "skewed_column_value_location_maps", null)
          skewed_column_values              = lookup(skewed_info.value, "skewed_column_values", null)
        }
      }
    }
  }

  dynamic "target_table" {
    for_each = var.target_table
    content {
      catalog_id    = target_table.value.catalog_id
      database_name = target_table.value.database_name
      name          = target_table.value.name
    }
  }
}