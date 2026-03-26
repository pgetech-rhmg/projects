/*
 * # AWS Transfer Family Access module. Granting access to AD Groups.
 * Terraform module which creates SAF2.0 aws_transfer_access in AWS.
*/
#
#  Filename    : aws/modules/transfer-family/modules/transfer-access/main.tf
#  Date        : 28 September 2022
#  Author      : TCS
#  Description : Transfer Family Access module creation for Granting access to AD Groups.
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

resource "aws_transfer_access" "transfer_access" {
  external_id    = var.external_id
  server_id      = var.server_id
  home_directory = var.home_directory

  dynamic "home_directory_mappings" {
    #Below optional block will run only when the arguments 'entry' and 'target' have values.
    for_each = var.home_directory_mappings.entry != null && var.home_directory_mappings.target != null ? [var.home_directory_mappings] : []
    content {
      entry  = var.home_directory_mappings.entry
      target = var.home_directory_mappings.target
    }
  }

  home_directory_type = var.home_directory_type
  policy              = var.policy

  dynamic "posix_profile" {
    #This block will run only when the arguments 'gid' and 'uid' have values.
    for_each = var.posix_profile.gid != null && var.posix_profile.uid != null ? [var.posix_profile] : []
    content {
      gid            = var.posix_profile.gid
      uid            = var.posix_profile.uid
      secondary_gids = var.posix_profile.secondary_gids
    }
  }

  role = var.role
}