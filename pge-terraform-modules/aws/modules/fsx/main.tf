/*
 * # AWS Fsx windows and lustre file system
 * Terraform module which creates SAF2.0 fsx windows and lustre file system in AWS.
*/

#
#  Filename    : aws/modules/fsx/main.tf
#  Date        : 02 sep 2022
#  Author      : TCS
#  Description : Terraform module creates a fsx windows and lustre File system
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

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassification type; exit 1"]
}

#Manages a FSx Windows File System. 
resource "aws_fsx_windows_file_system" "windows" {
  #This module can either use windows or lustre filesystem.
  #This resource will only perfom a single time execution. In count we will check the variable input,
  #if the input value is equal to windows then only this resource will be executed.
  count = var.file_system.file_system_type == "windows" ? 1 : 0

  storage_capacity                  = var.file_system.storage_capacity
  subnet_ids                        = var.subnet_ids
  throughput_capacity               = var.file_system.windows_throughput_capacity
  backup_id                         = var.backup_id
  active_directory_id               = var.file_system.windows_shared_active_directory_id
  aliases                           = var.file_system.windows_aliases
  automatic_backup_retention_days   = var.automatic_backup_retention_days
  copy_tags_to_backups              = var.copy_tags_to_backups
  daily_automatic_backup_start_time = var.daily_automatic_backup_start_time
  kms_key_id                        = var.kms_key_id
  security_group_ids                = var.security_group_ids
  skip_final_backup                 = var.file_system.windows_skip_final_backup
  weekly_maintenance_start_time     = var.weekly_maintenance_start_time
  deployment_type                   = var.file_system.deployment_type
  preferred_subnet_id               = var.file_system.windows_preferred_subnet_id
  storage_type                      = var.file_system.storage_type


  #This block will only be executed if any of the arguments file_access_audit_log_level or file_share_access_audit_log_level is not equal to null
  dynamic "audit_log_configuration" {
    for_each = var.file_system.windows_file_access_audit_log_level != null || var.file_system.windows_file_share_access_audit_log_level != null ? [true] : []
    content {
      audit_log_destination             = var.file_system.windows_audit_log_destination
      file_access_audit_log_level       = var.file_system.windows_file_access_audit_log_level
      file_share_access_audit_log_level = var.file_system.windows_file_share_access_audit_log_level
    }
  }

  tags = local.module_tags

  timeouts {
    create = try(var.timeouts.create, "45m")
    delete = try(var.timeouts.delete, "30m")
    update = try(var.timeouts.update, "45m")
  }
}

#Manages a FSx Lustre File System. 
resource "aws_fsx_lustre_file_system" "lustre" {
  #This module can either use windows or lustre filesystem.
  #This resource will only perfom a single time execution. In count we will check the variable input,
  #if the input value is equal to lustre then only this resource will be executed.
  count = var.file_system.file_system_type == "lustre" ? 1 : 0

  storage_capacity                  = var.file_system.storage_capacity
  subnet_ids                        = var.subnet_ids
  backup_id                         = var.backup_id
  export_path                       = var.file_system.lustre_export_path
  import_path                       = var.file_system.lustre_import_path
  imported_file_chunk_size          = var.file_system.lustre_imported_file_chunk_size
  security_group_ids                = var.security_group_ids
  weekly_maintenance_start_time     = var.weekly_maintenance_start_time
  deployment_type                   = var.file_system.deployment_type
  kms_key_id                        = var.kms_key_id
  per_unit_storage_throughput       = var.file_system.lustre_per_unit_storage_throughput
  automatic_backup_retention_days   = var.automatic_backup_retention_days
  storage_type                      = var.file_system.storage_type
  drive_cache_type                  = var.file_system.lustre_drive_cache_type
  daily_automatic_backup_start_time = var.daily_automatic_backup_start_time
  auto_import_policy                = var.file_system.lustre_auto_import_policy
  copy_tags_to_backups              = var.copy_tags_to_backups
  data_compression_type             = var.file_system.lustre_data_compression_type
  file_system_type_version          = var.file_system.lustre_file_system_type_version

  #This block will only be executed if the argument level is not equal to null
  dynamic "log_configuration" {
    for_each = var.file_system.lustre_log_configuration_level != null ? [true] : []
    content {
      destination = var.file_system.lustre_log_configuration_destination
      level       = var.file_system.lustre_log_configuration_level
    }
  }

  tags = local.module_tags

  timeouts {
    create = try(var.timeouts.create, "30m")
    update = try(var.timeouts.update, "30m")
    delete = try(var.timeouts.delete, "30m")
  }
}