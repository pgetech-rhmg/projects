/*
 * # AWS Glue Catalog Database module.
 * Terraform module which creates SAF2.0 Glue Catalog Database in AWS.
*/

#
#  Filename    : aws/modules/glue/modules/catalog_database/main.tf
#  Date        : 27 July 2022
#  Author      : TCS
#  Description : Glue Catalog Database Creation
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

# Module      : Creation of Glue Catalog Database
# Description : This terraform module creates a Glue Catalog Database.

resource "aws_glue_catalog_database" "glue_catalog_database" {
  name = var.name

  catalog_id = var.catalog_id

  #glue catalog database cannot use coalesce function for giving a default description since it conflicts with the target_database block.
  description  = var.description
  location_uri = var.location_uri
  parameters   = var.parameters

  #The target_database dynamic block is optional. If the end user provides values to the var.target_database variable,
  #then the dynamic target_database block will execute. When using the target_database, user shouldnot use any arguments
  #other than the name argument.
  dynamic "target_database" {
    for_each = var.target_database
    content {
      catalog_id    = target_database.value.catalog_id
      database_name = target_database.value.database_name
    }
  }

  #The create_table_default_permission dynamic block is optional. If the end user provides values to the
  #var.create_table_default_permission variable, then the dynamic create_table_default_permission block will 
  #execute with the provided values.
  dynamic "create_table_default_permission" {
    for_each = var.create_table_default_permission
    content {
      permissions = lookup(create_table_default_permission.value, "permissions", null)
      dynamic "principal" {
        for_each = lookup(create_table_default_permission.value, "principal", {})
        content {
          data_lake_principal_identifier = lookup(principal.value, "data_lake_principal_identifier", {})
        }
      }
    }
  }
}