/*
 * # AWS EFS module
 * Terraform module which creates SAF2.0 EFS in AWS
*/
#
# Filename    : modules/efs/main.tf
# Date        : 2 february 2021
# Author      : TCS
# Description : Elastic File System module main
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

# NOTE: Do not remove this data source if shown in tflint report

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassfication type; exit 1"]
}


#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_efs_file_system" "efs" {
  availability_zone_name = var.efs_one_zone_az
  encrypted              = "true"
  kms_key_id             = var.kms_key_id
  performance_mode       = var.performance_mode
  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia != null ? [true] : []
    content {
      transition_to_ia = var.transition_to_ia
    }
  }
  dynamic "lifecycle_policy" {
    for_each = var.enable_transition_to_primary_storage_class == true ? [true] : []
    content {
      transition_to_primary_storage_class = "AFTER_1_ACCESS"
    }
  }
  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput
  tags                            = local.module_tags
}

resource "aws_efs_access_point" "efs_access_point" {
  file_system_id = aws_efs_file_system.efs.id
  dynamic "posix_user" {
    for_each = var.posix_user_file_system != false ? [var.posix_user_file_system] : []
    content {
      gid            = var.posix_user_gid
      secondary_gids = var.posix_user_secondary_gids
      uid            = var.posix_user_uid
    }
  }

  dynamic "root_directory" {
    for_each = var.root_directory
    content {
      path = lookup(root_directory.value, "path")
      dynamic "creation_info" {
        for_each = try([root_directory.value.creation_info], [])
        content {
          owner_gid   = lookup(creation_info.value, "owner_gid")
          owner_uid   = lookup(creation_info.value, "owner_uid")
          permissions = lookup(creation_info.value, "permissions")
        }
      }
    }
  }

  tags = local.module_tags
}

resource "aws_efs_mount_target" "efs_mount_target" {

  count           = length(var.subnet_id)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = element(var.subnet_id, count.index)
  security_groups = var.security_groups
}

#Combines the user_defined_policy with the pge_compliance
data "aws_iam_policy_document" "combined" {
  override_policy_documents = [
    templatefile("${path.module}/efs_policy.json", { efs_arn = aws_efs_file_system.efs.arn }),
    var.policy
  ]
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id                     = aws_efs_file_system.efs.id
  bypass_policy_lockout_safety_check = true
  policy                             = data.aws_iam_policy_document.combined.json

}

resource "aws_efs_backup_policy" "efs_backup_policy" {
  file_system_id = aws_efs_file_system.efs.id
  backup_policy {
    status = var.backup_status
  }
}