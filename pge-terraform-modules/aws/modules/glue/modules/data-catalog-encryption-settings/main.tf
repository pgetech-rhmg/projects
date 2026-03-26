/*
 * # AWS Glue data catalog encryption settings module.
 * Terraform module which creates SAF2.0 Glue data catalog encryption settings in AWS.
 * This module to be executed first to enable glue catalog encyption.
 * When the encryption is turned on , all the future data catalog objects are encrypted.
 * The encryption settings are applied for the entire data catalog which includes: 
 * Databases, Tables, Partitions,Table Versions, Connections, User-defined Functions.
*/

#
#  Filename    : aws/modules/glue/modules/data-catalog-encryption-settings/main.tf
#  Date        : 22 August 2022
#  Author      : TCS
#  Description : Glue data catalog encryption settings Creation


terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : Creation of Glue data catalog encryption settings
# Description : This terraform module creates a Glue data catalog encryption settings.

resource "aws_glue_data_catalog_encryption_settings" "glue_data_catalog_encryption_settings" {
  data_catalog_encryption_settings {
    connection_password_encryption {
      return_connection_password_encrypted = true
      aws_kms_key_id                       = var.connection_password_aws_kms_key_id
    }
    encryption_at_rest {
      catalog_encryption_mode = "SSE-KMS"
      sse_aws_kms_key_id      = var.encryption_at_rest_sse_aws_kms_key_id
    }
  }
  catalog_id = var.catalog_id
}