/*
 * Athena Glue Submodule
 *
 * Description:
 *   Provisions AWS Glue Data Catalog resources to support
 *   Athena queries. This submodule creates a Glue database
 *   and an external table with a defined schema pointing
 *   to data stored in Amazon S3.
 *
 *   This module is optional and intended to be composed
 *   alongside the base Athena workgroup module.
 *
 * Resources Created:
 *   - aws_glue_catalog_database
 *   - aws_glue_catalog_table
 *
 * Module Path:
 *   aws/modules/athena/modules/glue
 *
 * Author:
 *   PG&E Cloud Engineering
 */



terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

module "s3_bucket" {
  source      = "app.terraform.io/pgetech/s3/aws"
  version     = "0.1.3"
  bucket_name = var.data_bucket
  tags        = local.module_tags
}

resource "aws_glue_catalog_database" "this" {
  name = var.glue_database_name
  tags = local.module_tags
}

resource "aws_glue_catalog_table" "this" {
  name          = var.glue_table_name
  database_name = aws_glue_catalog_database.this.name
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://${var.data_bucket}/${var.data_prefix}"
    input_format  = var.input_format
    output_format = var.output_format

    dynamic "columns" {
      for_each = var.columns
      content {
        name = columns.value.name
        type = columns.value.type
      }
    }

    ser_de_info {
      serialization_library = var.serialization_library
      parameters            = var.serde_parameters
    }
  }

}