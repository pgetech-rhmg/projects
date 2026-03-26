/*
 * # AWS Fsx lustre with data repository association
 * Terraform module which creates SAF2.0 fsx lustre with data repository association in AWS.
*/

#
#  Filename    : aws/modules/fsx/modules/lustre_with_data_repository_association/main.tf
#  Date        : 23 september 2022
#  Author      : TCS
#  Description : Terraform module creates a fsx lustre with data repository association
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


#Manages a FSx Lustre File System for data repository association.
resource "aws_fsx_lustre_file_system" "lustre" {

  storage_capacity              = var.storage_capacity
  subnet_ids                    = var.subnet_ids
  backup_id                     = var.backup_id
  security_group_ids            = var.security_group_ids
  weekly_maintenance_start_time = var.weekly_maintenance_start_time
  #Data Repository Associations are only compatible with Lustre File Systems with PERSISTENT_2 deployment type.
  deployment_type             = "PERSISTENT_2"
  kms_key_id                  = var.kms_key_id
  per_unit_storage_throughput = var.per_unit_storage_throughput
  #Data repositories cannot be linked to file systems that have file system backups enabled.
  #So we are setting the automatic_backup_retention_days to 0, which disables automatic backups.
  automatic_backup_retention_days = 0
  #SSD is only the only one supported in PERSISTENT_2 deployment types.
  storage_type             = "SSD"
  copy_tags_to_backups     = var.copy_tags_to_backups
  data_compression_type    = var.data_compression_type
  file_system_type_version = var.file_system_type_version

  #This block will only be executed if the argument level is not equal to DISABLED.
  dynamic "log_configuration" {
    for_each = var.lustre_log_configuration_level != "DISABLED" ? [true] : []
    content {
      destination = var.lustre_log_configuration_destination
      level       = var.lustre_log_configuration_level
    }
  }

  tags = local.module_tags

  timeouts {
    create = try(var.lustre_timeouts.create, "30m")
    update = try(var.lustre_timeouts.update, "30m")
    delete = try(var.lustre_timeouts.delete, "30m")
  }
}

#Manages a FSx for Lustre Data Repository Association.
#Data Repository Associations are only compatible with AWS FSx for Lustre File Systems and PERSISTENT_2 deployment type.
resource "aws_fsx_data_repository_association" "data_repository_association" {

  batch_import_meta_data_on_create = var.batch_import_meta_data_on_create
  data_repository_path             = var.data_repository_path
  file_system_id                   = aws_fsx_lustre_file_system.lustre.id
  file_system_path                 = var.file_system_path
  imported_file_chunk_size         = var.imported_file_chunk_size
  delete_data_in_filesystem        = var.delete_data_in_filesystem

  #The dynamic block s3 will be executed only if the variables auto_export_policy_events or auto_import_policy_events is not equal to null.
  dynamic "s3" {
    for_each = var.auto_export_policy_events != null || var.auto_import_policy_events != null ? [true] : []
    content {
      #The dynamic block auto_export_policy will be executed only if the variable auto_export_policy_events is not equal to null.
      dynamic "auto_export_policy" {
        for_each = var.auto_export_policy_events != null ? [true] : []
        content {
          events = var.auto_export_policy_events
        }
      }
      #The dynamic block auto_import_policy will be executed only if the variable auto_import_policy_events is not equal to null.
      dynamic "auto_import_policy" {
        for_each = var.auto_import_policy_events != null ? [true] : []
        content {
          events = var.auto_import_policy_events
        }
      }
    }
  }

  tags = local.module_tags

  timeouts {
    create = try(var.data_repository_association_timeouts.create, "10m")
    update = try(var.data_repository_association_timeouts.update, "10m")
    delete = try(var.data_repository_association_timeouts.delete, "10m")
  }
}