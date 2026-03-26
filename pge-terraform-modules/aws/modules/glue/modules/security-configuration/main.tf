/*
 * # AWS Glue Security Configuration module.
 * Terraform module which creates SAF2.0 Glue Security Configuration in AWS.
*/

#
#  Filename    : aws/modules/glue/modules/security-configuration/main.tf
#  Date        : 16 August 2022
#  Author      : TCS
#  Description : Glue Security Configuration Creation
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

# Module      : Creation of Glue Security Configuration.
# Description : This terraform module creates a Glue Security Configuration.

resource "aws_glue_security_configuration" "glue_security_configuration" {

  name = var.glue_security_configuration_name
  encryption_configuration {

    cloudwatch_encryption {
      cloudwatch_encryption_mode = "SSE-KMS"
      kms_key_arn                = var.glue_cloudwatch_encryption_kms_key_arn
    }

    job_bookmarks_encryption {
      job_bookmarks_encryption_mode = "CSE-KMS"
      kms_key_arn                   = var.glue_job_bookmarks_encryption_kms_key_arn
    }

    s3_encryption {
      s3_encryption_mode = "SSE-KMS"
      kms_key_arn        = var.glue_s3_encryption_kms_key_arn
    }

  }
}