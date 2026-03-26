/*
 * # AWS Storage gateway fsx file system association
 * Terraform module which creates SAF2.0 storage gateway fsx file system association in AWS.
*/

#
#  Filename    : aws/modules/storage_gateway/modules/fsx_file_system_association/main.tf
#  Date        : 06 october 2022
#  Author      : TCS
#  Description : Terraform module creates a storage gateway smb file system association
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

locals {
  namespace = "ccoe-tf-developers"
}

#Associate an Amazon FSx file system with the FSx File Gateway. 
#After the association process is complete, the file shares on the Amazon FSx file system are available for access through the gateway. 
resource "aws_storagegateway_file_system_association" "file_system_association" {

  gateway_arn           = var.gateway_arn
  location_arn          = var.location_arn
  username              = var.username
  password              = var.password
  audit_destination_arn = var.audit_destination_arn

  dynamic "cache_attributes" {
    for_each = var.cache_stale_timeout_in_seconds != null ? [true] : []
    content {
      cache_stale_timeout_in_seconds = var.cache_stale_timeout_in_seconds
    }
  }

  tags = merge(var.tags, { pge_team = local.namespace })
}