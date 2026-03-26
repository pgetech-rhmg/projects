/*
 * # RDS db_cluster module
 * Terraform module which creates SAF2.0 db_cluster module
*/
#
#  Filename    : modules/rds/main.tf
#  Date        : 5/9/2022
#  Author      : PGE
#  Description : AWS db_cluster main file.
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
  port          = coalesce(var.port, (var.engine == "aurora-postgresql" ? 5432 : 3306))
  is_serverless = var.engine_mode == "serverless" ? true : false

  cluster_identifier = lower(var.cluster_identifier)
  namespace          = "ccoe-tf-developers"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  is_managed_master_user_password = (var.global_cluster_identifier == null && var.manage_master_user_password) ? true : false
  is_dc_public_or_internal        = (var.tags["DataClassification"] == "Internal" || var.tags["DataClassification"] == "Public") ? true : false
  module_tags                     = merge(var.tags, { pge_team = local.namespace, Name = local.cluster_identifier, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}


data "external" "validate_kms" {
  count   = (!local.is_dc_public_or_internal && var.storage_encrypted == true && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassfication type and when storage_encypted is true ; exit 1"]
}

data "external" "validate_master_user_secret_kms" {
  count   = (!local.is_dc_public_or_internal && local.is_managed_master_user_password && var.master_user_secret_kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo master user secret kms is mandatory when managed master user password is true and for the DataClassification ; exit 1"]
}


resource "aws_rds_cluster" "aurora" {

  cluster_identifier = local.cluster_identifier

  engine         = var.engine
  engine_version = var.engine_version
  engine_mode    = var.engine_mode

  storage_encrypted           = var.storage_encrypted
  storage_type                = var.storage_type
  iops                        = var.iops
  allocated_storage           = var.allocated_storage
  kms_key_id                  = var.kms_key_id
  database_name               = var.database_name
  availability_zones          = var.availability_zones
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately

  db_cluster_parameter_group_name  = var.db_cluster_parameter_group_name
  db_instance_parameter_group_name = var.db_instance_parameter_group_name
  db_subnet_group_name             = var.db_subnet_group_name

  backtrack_window                = var.backtrack_window
  backup_retention_period         = var.backup_retention_period
  copy_tags_to_snapshot           = var.copy_tags_to_snapshot
  deletion_protection             = var.deletion_protection
  enable_http_endpoint            = var.enable_http_endpoint
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  final_snapshot_identifier      = var.final_snapshot_identifier
  global_cluster_identifier      = var.global_cluster_identifier
  enable_global_write_forwarding = var.enable_global_write_forwarding

  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iam_roles                           = var.iam_roles
  manage_master_user_password         = var.global_cluster_identifier == null && var.manage_master_user_password ? var.manage_master_user_password : null
  master_user_secret_kms_key_id       = var.global_cluster_identifier == null && var.manage_master_user_password ? var.master_user_secret_kms_key_id : null
  master_password                     = var.is_primary_cluster && !var.manage_master_user_password ? var.master_password : null
  master_username                     = var.is_primary_cluster ? var.master_username : null
  port                                = local.port

  domain               = var.domain
  domain_iam_role_name = var.domain_iam_role_name

  preferred_backup_window               = var.preferred_backup_window
  preferred_maintenance_window          = var.preferred_maintenance_window
  performance_insights_enabled          = var.cluster_performance_insights_enabled
  performance_insights_kms_key_id       = var.cluster_performance_insights_kms_key_id
  performance_insights_retention_period = var.cluster_performance_insights_retention_period
  replication_source_identifier         = var.replication_source_identifier

  vpc_security_group_ids = var.vpc_security_group_ids

  skip_final_snapshot = var.skip_final_snapshot
  snapshot_identifier = var.snapshot_identifier
  source_region       = var.source_region

  dynamic "scaling_configuration" {
    for_each = length(keys(var.scaling_configuration)) == 0 || !local.is_serverless ? [] : [var.scaling_configuration]

    content {
      auto_pause               = lookup(scaling_configuration.value, "auto_pause", null)
      max_capacity             = lookup(scaling_configuration.value, "max_capacity", null)
      min_capacity             = lookup(scaling_configuration.value, "min_capacity", null)
      seconds_until_auto_pause = lookup(scaling_configuration.value, "seconds_until_auto_pause", null)
      timeout_action           = lookup(scaling_configuration.value, "timeout_action", null)
    }
  }
  dynamic "serverlessv2_scaling_configuration" {
    for_each = length(var.serverlessv2_scaling_configuration) > 0 && var.engine_mode == "provisioned" ? [var.serverlessv2_scaling_configuration] : []

    content {
      max_capacity             = serverlessv2_scaling_configuration.value.max_capacity
      min_capacity             = serverlessv2_scaling_configuration.value.min_capacity
      seconds_until_auto_pause = lookup(serverlessv2_scaling_configuration.value, "seconds_until_auto_pause", null)
    }
  }

  #Does not apply to aurora postgresql.  s3_import conflicts with snapshot_identifier
  dynamic "s3_import" {
    for_each = var.s3_import != null && !local.is_serverless ? [var.s3_import] : []
    content {
      source_engine         = "mysql"
      source_engine_version = s3_import.value.source_engine_version
      bucket_name           = s3_import.value.bucket_name
      bucket_prefix         = lookup(s3_import.value, "bucket_prefix", null)
      ingestion_role        = s3_import.value.ingestion_role
    }
  }

  dynamic "restore_to_point_in_time" {
    for_each = length(keys(var.restore_to_point_in_time)) == 0 ? [] : [var.restore_to_point_in_time]

    content {
      source_cluster_identifier  = restore_to_point_in_time.value.source_cluster_identifier
      restore_type               = lookup(restore_to_point_in_time.value, "restore_type", null)
      use_latest_restorable_time = lookup(restore_to_point_in_time.value, "use_latest_restorable_time", null)
      restore_to_time            = lookup(restore_to_point_in_time.value, "restore_to_time", null)
    }
  }

  lifecycle {
    ignore_changes = [
      # See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster#replication_source_identifier
      # Since this is used either in read-replica clusters or global clusters, this should be acceptable to specify
      replication_source_identifier,
      # See docs here https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_global_cluster#new-global-cluster-from-existing-db-cluster
      global_cluster_identifier
    ]
  }
  tags = local.module_tags


  timeouts {
    create = lookup(var.timeouts, "create", null)
    delete = lookup(var.timeouts, "delete", null)
    update = lookup(var.timeouts, "update", null)
  }
}

