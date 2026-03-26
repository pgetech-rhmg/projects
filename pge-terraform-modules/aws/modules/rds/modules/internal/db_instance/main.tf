/*
 * # RDS db_instance module
 * Terraform module which creates SAF2.0 db_instance module
*/
#
#  Filename    : modules/rds/modules/internal/db_instance/main.tf
#  Date        : 3/2/2022
#  Author      : PGE
#  Description : AWS db_instance main file.
#
terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}



locals {

  is_mssql   = element(split("-", var.engine), 0) == "sqlserver"
  identifier = lower(var.identifier)
  namespace  = "ccoe-tf-developers"
  # Replicas will use source metadata
  is_replica = var.replicate_source_db != null
}

# Ref. https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html#genref-aws-service-namespaces
data "aws_partition" "current" {}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags                     = merge(var.tags, { Name = format("%s", local.identifier), pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  is_managed_master_user_password = (!local.is_replica && var.manage_master_user_password) ? true : false
  is_dc_public_or_internal        = (var.tags["DataClassification"] == "Internal" || var.tags["DataClassification"] == "Public") ? true : false
}

resource "random_id" "snapshot_identifier" {
  count = var.create && !var.skip_final_snapshot ? 1 : 0

  keepers = {
    id = local.identifier
  }

  byte_length = 4
}

data "external" "validate_kms" {
  count   = (!local.is_dc_public_or_internal && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassfication type ; exit 1"]
}


data "external" "validate_master_user_secret_kms" {
  count   = (!local.is_dc_public_or_internal && var.manage_master_user_password && var.master_user_secret_kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo master user secret kms is mandatory when managed master user password is true and for the DataClassification ; exit 1"]
}


resource "aws_db_instance" "this" {
  count = var.create && false == local.is_mssql ? 1 : 0

  identifier        = local.identifier
  engine            = local.is_replica ? null : var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = local.is_replica ? null : var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id
  license_model     = var.license_model

  db_name = var.db_name


  username                            = !local.is_replica ? var.username : null
  password                            = !local.is_replica && var.manage_master_user_password ? null : var.password
  manage_master_user_password         = !local.is_replica && var.manage_master_user_password ? var.manage_master_user_password : null
  master_user_secret_kms_key_id       = var.master_user_secret_kms_key_id
  port                                = var.port
  domain                              = var.domain
  domain_iam_role_name                = var.domain_iam_role_name
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name
  parameter_group_name   = var.parameter_group_name
  option_group_name      = var.option_group_name

  availability_zone   = var.availability_zone
  multi_az            = var.multi_az
  iops                = var.iops
  storage_throughput  = var.storage_throughput
  publicly_accessible = var.publicly_accessible
  ca_cert_identifier  = var.ca_cert_identifier

  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window

  snapshot_identifier   = var.snapshot_identifier
  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  skip_final_snapshot   = var.skip_final_snapshot

  final_snapshot_identifier = var.skip_final_snapshot ? null : coalesce(var.final_snapshot_identifier, "${var.final_snapshot_identifier_prefix}-${local.identifier}-${random_id.snapshot_identifier[0].hex}")

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  replicate_source_db     = var.replicate_source_db
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  max_allocated_storage   = var.max_allocated_storage
  monitoring_interval     = var.monitoring_interval
  monitoring_role_arn     = var.monitoring_role_arn

  nchar_character_set_name        = var.nchar_character_set_name
  character_set_name              = var.character_set_name
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  deletion_protection      = var.deletion_protection
  delete_automated_backups = var.delete_automated_backups
  replica_mode             = var.replica_mode

  dynamic "restore_to_point_in_time" {
    for_each = var.restore_to_point_in_time != null ? [true] : []

    content {
      restore_time                  = lookup(restore_to_point_in_time.value, "restore_time", null)
      source_db_instance_identifier = lookup(restore_to_point_in_time.value, "source_db_instance_identifier", null)
      source_dbi_resource_id        = lookup(restore_to_point_in_time.value, "source_dbi_resource_id", null)
      use_latest_restorable_time    = lookup(restore_to_point_in_time.value, "use_latest_restorable_time", null)
    }
  }


  tags = local.module_tags

  timeouts {
    create = lookup(var.timeouts, "create", null)
    delete = lookup(var.timeouts, "delete", null)
    update = lookup(var.timeouts, "update", null)
  }

}

resource "aws_db_instance" "this_mssql" {
  count = var.create && local.is_mssql ? 1 : 0

  identifier        = local.identifier
  engine            = local.is_replica ? null : var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = local.is_replica ? null : var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id
  license_model     = var.license_model

  db_name                             = var.db_name
  username                            = !local.is_replica ? var.username : null
  password                            = !local.is_replica && var.manage_master_user_password ? null : var.password
  manage_master_user_password         = !local.is_replica && var.manage_master_user_password ? var.manage_master_user_password : null
  master_user_secret_kms_key_id       = var.master_user_secret_kms_key_id
  port                                = var.port
  domain                              = var.domain
  domain_iam_role_name                = var.domain_iam_role_name
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name
  parameter_group_name   = var.parameter_group_name
  option_group_name      = var.option_group_name

  availability_zone   = var.availability_zone
  multi_az            = var.multi_az
  iops                = var.iops
  storage_throughput  = var.storage_throughput
  publicly_accessible = var.publicly_accessible
  ca_cert_identifier  = var.ca_cert_identifier

  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window

  snapshot_identifier       = var.snapshot_identifier
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : coalesce(var.final_snapshot_identifier, "${var.final_snapshot_identifier_prefix}-${local.identifier}-${random_id.snapshot_identifier[0].hex}")

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  replicate_source_db     = var.replicate_source_db
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  max_allocated_storage   = var.max_allocated_storage
  monitoring_interval     = var.monitoring_interval
  monitoring_role_arn     = var.monitoring_role_arn

  character_set_name              = var.character_set_name
  timezone                        = var.timezone # MSSQL only
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  deletion_protection      = var.deletion_protection
  delete_automated_backups = var.delete_automated_backups

  tags = local.module_tags


  timeouts {
    create = lookup(var.timeouts, "create", null)
    delete = lookup(var.timeouts, "delete", null)
    update = lookup(var.timeouts, "update", null)
  }
}


