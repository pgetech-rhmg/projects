/*
 * # AWS Glue partition module.
 * Terraform module which creates SAF2.0 Glue partition in AWS.
*/

#
#  Filename    : aws/modules/glue/module/partition/main.tf
#  Date        : 21 August 2022
#  Author      : TCS
#  Description : Glue partition Creation
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

# Module      : Creation of Glue partition.
# Description : This terraform module creates a Glue partition.

resource "aws_glue_partition" "glue_partition" {
  database_name    = var.glue_partition_database_name
  table_name       = var.glue_partition_table_name
  partition_values = var.glue_partition_values
  catalog_id       = var.glue_partition_catalog_id
  parameters       = var.glue_partition_parameters

  dynamic "storage_descriptor" {

    #The 'storage_descriptor' dynamic block is optional and execute only once. Below optional block will run only if
    #value of 'glue_partition_storage_descriptor' is provided. The variable 'glue_partition_storage_descriptor' is a map
    #so the end user can pass the value in key-value pairs from the example.
    for_each = var.glue_partition_storage_descriptor != null ? [var.glue_partition_storage_descriptor] : []
    content {
      location                  = lookup(storage_descriptor.value, "location", null)
      input_format              = lookup(storage_descriptor.value, "input_format", null)
      output_format             = lookup(storage_descriptor.value, "output_format", null)
      compressed                = lookup(storage_descriptor.value, "compressed", null)
      number_of_buckets         = lookup(storage_descriptor.value, "number_of_buckets", null)
      bucket_columns            = lookup(storage_descriptor.value, "bucket_columns", [])
      parameters                = lookup(storage_descriptor.value, "parameters", {})
      stored_as_sub_directories = lookup(storage_descriptor.value, "stored_as_sub_directories", null)

      dynamic "columns" {
        #The 'columns' optional block, can iterate multiple times if multiple values are passed for the variable 'glue_partition_storage_descriptor'.
        for_each = lookup(storage_descriptor.value, "columns", {})
        content {
          name    = columns.value.name
          type    = lookup(columns.value, "type", null)
          comment = lookup(columns.value, "comment", null)
        }
      }

      dynamic "ser_de_info" {
        #The 'ser_de_info' optional block, can iterate only once when the end user pass value for the variable 'glue_partition_storage_descriptor'.
        for_each = lookup(storage_descriptor.value, "ser_de_info", {}) != {} ? [lookup(storage_descriptor.value, "ser_de_info", {})] : []
        content {
          name                  = lookup(ser_de_info.value, "name", null)
          parameters            = lookup(ser_de_info.value, "parameters", {})
          serialization_library = lookup(ser_de_info.value, "serialization_library", null)
        }
      }

      dynamic "sort_columns" {
        #The 'sort_columns' optional block, can iterate multiple times if multiple values are passed for the variable 'glue_partition_storage_descriptor'.
        for_each = lookup(storage_descriptor.value, "sort_columns", {})
        content {
          column     = sort_columns.value.column
          sort_order = sort_columns.value.sort_order
        }
      }

      dynamic "skewed_info" {
        #The 'skewed_info' optional block, can iterate only once when the end user pass value for the variable 'glue_partition_storage_descriptor'.
        for_each = lookup(storage_descriptor.value, "skewed_info", {}) != {} ? [lookup(storage_descriptor.value, "skewed_info", {})] : []
        content {
          skewed_column_names               = lookup(skewed_info.value, "skewed_column_names", null)
          skewed_column_value_location_maps = lookup(skewed_info.value, "skewed_column_value_location_maps", {})
          skewed_column_values              = lookup(skewed_info.value, "skewed_column_values", null)
        }
      }
    }
  }
}