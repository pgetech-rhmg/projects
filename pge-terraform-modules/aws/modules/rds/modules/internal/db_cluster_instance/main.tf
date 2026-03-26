/*
 * # RDS db_cluster_instance module
 * Terraform module which creates SAF2.0 db_cluster_instance module
*/
#
#  Filename    : modules/rds/modules/internal/db_cluster_instance/main.tf
#  Date        : 5/9/2022
#  Author      : PGE
#  Description : AWS db_cluster_instance main file.
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
  identifier = lower(var.identifier)
  namespace  = "ccoe-tf-developers"

  # Validation: If custom_instance_names is provided, it must match cluster_instance_count
  validate_custom_names = length(var.custom_instance_names) == 0 || length(var.custom_instance_names) == var.cluster_instance_count ? true : file("ERROR: custom_instance_names length must match cluster_instance_count")
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags            = merge(var.tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  cluster_instances_tags = merge(var.tags, { Name = local.identifier, pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}
resource "aws_rds_cluster_instance" "cluster_instances" {

  # Notes:
  # Do not set preferred_backup_window - its set at the cluster level and will error if provided here

  count = var.cluster_instance_count > 0 ? var.cluster_instance_count : 0

  identifier = length(var.custom_instance_names) > 0 ? var.custom_instance_names[count.index] : "${local.identifier}-${count.index}"

  cluster_identifier                    = var.cluster_identifier
  engine                                = var.engine
  engine_version                        = var.engine_version
  instance_class                        = var.instance_class
  publicly_accessible                   = false
  db_subnet_group_name                  = var.db_subnet_group_name
  db_parameter_group_name               = var.db_parameter_group_name
  apply_immediately                     = var.apply_immediately
  monitoring_role_arn                   = var.monitoring_role_arn
  monitoring_interval                   = var.monitoring_interval
  promotion_tier                        = var.promotion_tier
  availability_zone                     = var.availability_zone
  preferred_maintenance_window          = var.preferred_maintenance_window
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period
  copy_tags_to_snapshot                 = true
  ca_cert_identifier                    = var.ca_cert_identifier

  timeouts {
    create = lookup(var.instance_timeouts, "create", null)
    update = lookup(var.instance_timeouts, "update", null)
    delete = lookup(var.instance_timeouts, "delete", null)
  }

  tags = local.cluster_instances_tags

}


#Cloudwatch Metric Alarms Module
module "db_cloudwatch_metric_alarms" {
  count = length(aws_rds_cluster_instance.cluster_instances)

  source = "../db_cloudwatch_metric_alarms"
  tags   = local.module_tags

  actions_alarm                             = var.actions_alarm
  actions_ok                                = var.actions_ok
  db_instance_id                            = aws_rds_cluster_instance.cluster_instances[count.index].id
  evaluation_period                         = var.evaluation_period
  anomaly_band_width                        = var.anomaly_band_width
  create_anomaly_alarm                      = var.create_anomaly_alarm
  anomaly_period                            = var.anomaly_period
  statistic_period                          = var.statistic_period
  db_instance_class                         = var.instance_class
  cpu_credit_balance_too_low_threshold      = var.cpu_credit_balance_too_low_threshold
  cpu_utilization_too_high_threshold        = var.cpu_utilization_too_high_threshold
  disk_queue_depth_too_high_threshold       = var.disk_queue_depth_too_high_threshold
  disk_free_storage_space_too_low_threshold = var.disk_free_storage_space_too_low_threshold
  disk_burst_balance_too_low_threshold      = var.disk_burst_balance_too_low_threshold
  memory_freeable_too_low_threshold         = var.memory_freeable_too_low_threshold
  memory_swap_usage_too_high_threshold      = var.memory_swap_usage_too_high_threshold

}
