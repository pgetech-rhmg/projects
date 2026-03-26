/*
*#AWS Neptune module
*Terraform module which creates cluster
*/
#Filename     : aws/modules/neptune/modules/main.tf 
#database     : 02 Aug 2022
#Author       : TCS
#Description  : Terraform module for creation of cluster
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

#Module : Neptune
#Description : This terraform module creates cluster

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
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key arn is mandatory for the DataClassification type; exit 1"]
}


resource "aws_neptune_cluster" "neptune_cluster" {

  #Neptune engine is only 'neptune'
  engine         = "neptune"
  engine_version = var.engine_version

  allow_major_version_upgrade    = var.allow_major_version_upgrade
  port                           = var.port
  enable_cloudwatch_logs_exports = var.enable_cloudwatch_logs_exports
  apply_immediately              = var.apply_immediately
  replication_source_identifier  = var.replication_source_identifier
  cluster_identifier             = var.cluster_identifier
  availability_zones             = var.availability_zones
  vpc_security_group_ids         = var.vpc_security_group_ids
  iam_roles                      = var.iam_roles

  #As per SAF rules #27 IAM database authentication feature is enabled
  iam_database_authentication_enabled = "true"

  #As per SAF rules encryption at rest is enabled 
  storage_encrypted                    = "true"
  kms_key_arn                          = var.kms_key_arn
  neptune_subnet_group_name            = var.neptune_subnet_group_name
  neptune_cluster_parameter_group_name = var.neptune_cluster_parameter_group_name
  backup_retention_period              = var.backup_retention_period
  preferred_backup_window              = var.preferred_backup_window
  preferred_maintenance_window         = var.preferred_maintenance_window
  copy_tags_to_snapshot                = var.copy_tags_to_snapshot
  final_snapshot_identifier            = var.final_snapshot_identifier
  skip_final_snapshot                  = var.skip_final_snapshot
  snapshot_identifier                  = var.snapshot_identifier
  deletion_protection                  = var.deletion_protection

  timeouts {
    create = try(var.timeouts.create, "120m")
    update = try(var.timeouts.update, "120m")
    delete = try(var.timeouts.delete, "120m")
  }

  tags = local.module_tags

}