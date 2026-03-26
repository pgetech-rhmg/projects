/*
 * # AWS DataSync module
 * Terraform module which creates SAF2.0 DataSync s3 location resources in AWS.
*/
#
#  Filename    : modules/datasync/s3_location/main.tf
#  Date        : 09 May 2024
#  Author      : Eric Barnard (e6bo@pge.com)
#  Description : The module will create an s3 location for DataSync
# 

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 1.0"
    }
  }
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_datasync_location_s3" "this" {
  s3_bucket_arn    = var.s3_location_arn
  subdirectory     = var.s3_location_subdirectory
  s3_storage_class = var.s3_storage_class

  s3_config {
    bucket_access_role_arn = var.s3_datasync_access_role
  }

  tags = local.module_tags
}