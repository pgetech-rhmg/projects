/*
 * # AWS Glue Catalog Database, Catalog Table, Glue Partition, Glue Partition Index and User Defined Function creation example
 * Terraform module which creates SAF2.0 Glue registry resources in AWS. 
 * While creating catalog table using s3 as the storage_descriptor location, then grant data location permissions from the AWS Lake Formation to s3.
*/
#
# Filename    : aws/modules/glue/examples/catalog_database_with_catalog_table/main.tf
# Date        : 27 July 2022
# Author      : TCS
# Description : Terraform module example for glue catalog database with glue catalog table, glue partition, glue partition index and user defined function.
#

locals {
  name = "${var.name}_${random_string.name.result}"
}

data "aws_caller_identity" "current" {}

#########################################
# Create Glue Catalog Database
#########################################

module "catalog_database" {
  source = "../../modules/catalog_database"

  #Here random_string resource is not used, since the variable validation doesnot work while using random_string.
  name                            = var.name
  description                     = var.description
  create_table_default_permission = var.create_table_default_permission
}

#########################################
# Create Glue Catalog Table
#########################################

module "catalog_table" {
  source = "../../modules/catalog_table"

  name = local.name

  #name of the catalog_database
  database_name      = var.name
  catalog_id         = var.account_num
  table_type         = var.table_type
  parameters         = var.parameters
  partition_keys     = var.partition_keys
  storage_descriptor = var.storage_descriptor

  depends_on = [
    module.catalog_database
  ]
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 3
  upper   = false
  special = false
}

module "glue_partition_index" {
  source = "../../modules/glue_partition_index"

  partition_table_name    = module.catalog_table.name
  partition_database_name = module.catalog_database.name
  partition_catalog_id    = var.account_num

  partition_index = [{
    index_name = var.partition_index_name
    keys       = var.partition_index_keys
  }]

}
#########################################
# Create Glue Partition
#########################################

module "partition" {
  source = "../../modules/partition"

  glue_partition_database_name = var.name
  glue_partition_table_name    = local.name
  glue_partition_values        = var.glue_partition_values
  glue_partition_catalog_id    = var.account_num

  glue_partition_storage_descriptor = {
    location                  = var.location
    input_format              = var.input_format
    output_format             = var.output_format
    compressed                = var.compressed
    stored_as_sub_directories = var.stored_as_sub_directories
    parameters                = var.partition_parameters
    columns = [{
      name = var.columns_name_1
      type = var.columns_type_1
      },
      {
        name = var.columns_name_2
        type = var.columns_type_2
      },
      {
        name = var.columns_name_3
        type = var.columns_type_3
      },
      {
        name = var.columns_name_4
        type = var.columns_type_4
    }]

    ser_de_info = {
      name                  = var.ser_de_info_name
      serialization_library = var.ser_de_info_serializationLib
      parameters            = var.ser_de_info_parameters
    }
  }

  depends_on = [
    module.catalog_database,
    module.catalog_table
  ]
}

#########################################
# Create Glue User Defined Function
#########################################

module "user_defined_function" {
  source     = "../../modules/user_defined_function"
  depends_on = [module.catalog_database]

  name          = var.function_name
  catalog_id    = data.aws_caller_identity.current.account_id
  database_name = var.name
  class_name    = var.class_name
  owner_name    = var.owner_name
  owner_type    = var.owner_type

  resource_uris = [{
    resource_type = var.resource_type
    uri           = var.uri
  }]
}