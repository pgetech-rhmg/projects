/*
* # AWS storagegateway nfs_file_share module
* # Terraform module which creates aws_storagegateway_nfs_file_share
*/
# Filename     : aws/modules/storagegateway/modules/nfs_file_share/main.tf 
# Date         : 28 Sep 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of aws_storagegateway_nfs_file_share

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  namespace                      = "ccoe-tf-developers"
  nfs_file_share_defaults_enable = var.nfs_file_share_defaults.directory_mode != null || var.nfs_file_share_defaults.file_mode != null || var.nfs_file_share_defaults.group_id != null || var.nfs_file_share_defaults.owner_id != null
}

resource "aws_storagegateway_nfs_file_share" "nfs" {
  client_list             = var.client_list
  gateway_arn             = var.gateway_arn
  location_arn            = var.location_arn
  vpc_endpoint_dns_name   = var.vpc_endpoint_bucket.vpc_endpoint_dns_name
  bucket_region           = var.vpc_endpoint_bucket.bucket_region
  role_arn                = var.role_arn
  audit_destination_arn   = var.audit_destination_arn
  default_storage_class   = var.default_storage_class
  guess_mime_type_enabled = var.guess_mime_type_enabled
  kms_encrypted           = var.kms_encrypted
  kms_key_arn             = var.kms_key_arn
  #Setting object_acl to private as per SAF rule #29.
  object_acl          = "private"
  read_only           = var.read_only
  requester_pays      = var.requester_pays
  squash              = var.squash
  file_share_name     = var.file_share_name
  notification_policy = var.notification_policy

  # nfs_file_share_defaults is optional so this block will execute only when user provides the reqired input until it will be disabled
  dynamic "nfs_file_share_defaults" {
    for_each = local.nfs_file_share_defaults_enable ? [true] : []
    content {
      directory_mode = var.nfs_file_share_defaults.directory_mode
      file_mode      = var.nfs_file_share_defaults.file_mode
      group_id       = var.nfs_file_share_defaults.group_id
      owner_id       = var.nfs_file_share_defaults.owner_id
    }
  }

  dynamic "cache_attributes" {
    for_each = var.cache_stale_timeout_in_seconds != null ? [true] : []
    content {
      cache_stale_timeout_in_seconds = var.cache_stale_timeout_in_seconds
    }
  }

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.update
    update = var.timeouts.delete
  }

  tags = merge(var.tags, { pge_team = local.namespace })
}