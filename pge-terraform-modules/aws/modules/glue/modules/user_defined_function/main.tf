/*
 * # AWS Glue user defined function
 * Terraform module which creates SAF2.0 glue user defined function in AWS.
*/

#
#  Filename    : aws/modules/glue/module/user_defined_function/main.tf
#  Date        : 25 Aug 2022
#  Author      : TCS
#  Description : Terraform module creates a glue user defined function
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

# Provides a Glue User Defined Function Resource.
resource "aws_glue_user_defined_function" "user_defined_function" {

  name          = var.name
  catalog_id    = var.catalog_id
  database_name = var.database_name
  class_name    = var.class_name
  owner_name    = var.owner_name
  owner_type    = var.owner_type


  dynamic "resource_uris" {
    for_each = var.resource_uris
    content {
      resource_type = resource_uris.value.resource_type
      uri           = resource_uris.value.uri
    }
  }
}