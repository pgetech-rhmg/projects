/*
* # AWS Glue Partition Index module.
* Terraform module which creates SAF2.0 Glue Partition Index in AWS.
*/
#  Filename :aws/modules/glue/modules/glue_partition_index/main.terraform
#  Date :31 August 2022
#  Author :TCS
#  Description : Glue Partition Index Creation

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module  : Creation of Glue Partition Index
# Description  : This terraform module creates a Glue Partition Index.terraform


resource "aws_glue_partition_index" "glue_partition_index" {

  table_name    = var.partition_table_name
  database_name = var.partition_database_name

  dynamic "partition_index" {
    for_each = var.partition_index
    content {
      index_name = partition_index.value.index_name
      keys       = partition_index.value.keys
    }
  }
  timeouts {
    create = try(var.timeouts.create, "10m")
    delete = try(var.timeouts.delete, "10m")
  }

  catalog_id = var.partition_catalog_id
}