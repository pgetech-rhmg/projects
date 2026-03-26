/*
 * # AWS DocumentDB Cluster
 * Terraform module which creates SAF2.0 DocumentDB Cluster in AWS
*/

#
#  Filename    : aws/modules/documentdb/main.tf
#  Date        : 09 August 2022
#  Author      : TCS
#  Description : Terraform module for creation of cluster
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

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.cluster_kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



#Manages a DocDB Cluster.
resource "aws_docdb_cluster" "docdb_cluster" {

  apply_immediately               = var.cluster_apply_immediately
  availability_zones              = var.cluster_availability_zones
  backup_retention_period         = var.cluster_backup_retention_period
  cluster_identifier              = var.cluster_identifier
  db_subnet_group_name            = var.db_subnet_group_name
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name
  deletion_protection             = var.cluster_deletion_protection
  enabled_cloudwatch_logs_exports = var.cluster_enabled_cloudwatch_logs_exports
  engine_version                  = var.cluster_engine_version
  engine                          = var.cluster_engine
  final_snapshot_identifier       = var.cluster_final_snapshot_identifier
  global_cluster_identifier       = var.cluster_global_cluster_identifier
  kms_key_id                      = var.cluster_kms_key_id
  master_password                 = var.cluster_master_password
  master_username                 = var.cluster_master_username
  port                            = var.cluster_port
  preferred_backup_window         = var.cluster_preferred_backup_window
  preferred_maintenance_window    = var.cluster_preferred_maintenance_window
  skip_final_snapshot             = var.cluster_skip_final_snapshot
  snapshot_identifier             = var.cluster_snapshot_identifier
  #As per SAF rule storage_encrypted should be always true
  storage_encrypted      = true
  vpc_security_group_ids = var.cluster_vpc_security_group_ids
  tags                   = local.module_tags

  timeouts {
    create = try(var.cluster_timeouts.create, "120m")
    update = try(var.cluster_timeouts.update, "120m")
    delete = try(var.cluster_timeouts.delete, "120m")
  }
}
