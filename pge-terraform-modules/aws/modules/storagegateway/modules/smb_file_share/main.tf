/*
 * # AWS Storage gateway smb file share
 * Terraform module which creates SAF2.0 storage gateway smb file share in AWS.
*/

#
#  Filename    : aws/modules/storage_gateway/modules/smb_file_share/main.tf
#  Date        : 29 september 2022
#  Author      : TCS
#  Description : Terraform module creates a storage gateway smb file share
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

#Manages an AWS Storage Gateway SMB File Share.
resource "aws_storagegateway_smb_file_share" "smb_file_share" {

  gateway_arn           = var.gateway_arn
  location_arn          = var.location_arn
  vpc_endpoint_dns_name = var.vpc_endpoint_bucket.vpc_endpoint_dns_name
  bucket_region         = var.vpc_endpoint_bucket.bucket_region
  role_arn              = var.role_arn
  admin_user_list       = var.admin_user_list
  #Setting authentication to ActiveDirectory as per SAF rule #8.
  authentication          = "ActiveDirectory"
  audit_destination_arn   = var.audit_destination_arn
  default_storage_class   = var.default_storage_class
  file_share_name         = var.file_share_name
  guess_mime_type_enabled = var.guess_mime_type_enabled
  invalid_user_list       = var.invalid_user_list
  kms_encrypted           = var.kms_encrypted
  kms_key_arn             = var.kms_key_arn
  object_acl              = var.object_acl
  oplocks_enabled         = var.oplocks_enabled
  read_only               = var.read_only
  requester_pays          = var.requester_pays
  #Setting smb_acl_enabled to true as per SAF rule #8.
  smb_acl_enabled          = true
  case_sensitivity         = var.case_sensitivity
  valid_user_list          = var.valid_user_list
  access_based_enumeration = var.access_based_enumeration
  notification_policy      = var.notification_policy

  dynamic "cache_attributes" {
    for_each = var.cache_stale_timeout_in_seconds != null ? [true] : []
    content {
      cache_stale_timeout_in_seconds = var.cache_stale_timeout_in_seconds
    }
  }

  tags = merge(var.tags, { pge_team = local.namespace })

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.update
    update = var.timeouts.delete
  }

}