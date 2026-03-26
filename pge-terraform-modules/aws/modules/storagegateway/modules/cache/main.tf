/*
 * # AWS Storage gateway cache
 * Terraform module which creates SAF2.0 storage gateway cache in AWS.
*/

#
#  Filename    : aws/modules/storage_gateway/modules/cache/main.tf
#  Date        : 06 october 2022
#  Author      : TCS
#  Description : Terraform module creates a storage gateway cache
#

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_storagegateway_cache" "cache" {
  disk_id     = var.disk_id
  gateway_arn = var.gateway_arn
}