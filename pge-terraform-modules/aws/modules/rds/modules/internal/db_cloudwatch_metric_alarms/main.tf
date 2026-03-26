#
#  Filename    : modules/rds/modules/internal/db_cloudwatch_metric_alarms/main.tf
#  Date        : 3/2/2022
#  Author      : PGE
#  Description : Multiple AWS Cloudwatch metric-alarm creation modules.  Metric alarm for credit
#                balance too low not included as instances used will be R4 & R5
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
  namespace = "AWS/RDS"
  statistic = "Average"
  rds_tags = {
    RDS = var.db_instance_id
  }
  metric_tags = merge(var.tags, local.rds_tags)
  tf_tag      = "ccoe-tf-developers"

}
#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(local.metric_tags, { pge_team = local.tf_tag, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}
# CPU Utilization
module "cpu_utilization_too_high" {
  count = var.create_high_cpu_alarm ? 1 : 0

  source  = "app.terraform.io/pgetech/cloudwatch/aws"
  version = "0.1.3"

  alarm_name          = "rds-${var.db_instance_id}-highCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = local.namespace
  period              = var.statistic_period
  statistic           = local.statistic
  threshold           = var.cpu_utilization_too_high_threshold
  alarm_description   = "Average database CPU utilization is too high."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok
  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  tags = local.module_tags
}

module "cpu_credit_balance_too_low" {
  count = var.create_low_cpu_credit_alarm ? length(regexall("(t2|t3|t3a|t4g)", var.db_instance_class)) > 0 ? 1 : 0 : 0

  source  = "app.terraform.io/pgetech/cloudwatch/aws"
  version = "0.1.3"

  alarm_name          = "rds-${var.db_instance_id}-lowCPUCreditBalance"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "CPUCreditBalance"
  namespace           = local.namespace
  period              = var.statistic_period
  statistic           = local.statistic
  threshold           = var.cpu_credit_balance_too_low_threshold
  alarm_description   = "Average database CPU credit balance is too low, a negative performance impact is imminent."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  tags = local.module_tags
}

# Disk Utilization
module "disk_queue_depth_too_high" {
  count = var.create_high_queue_depth_alarm ? 1 : 0

  source  = "app.terraform.io/pgetech/cloudwatch/aws"
  version = "0.1.3"

  alarm_name          = "rds-${var.db_instance_id}-highDiskQueueDepth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "DiskQueueDepth"
  namespace           = local.namespace
  period              = var.statistic_period
  statistic           = local.statistic
  threshold           = var.disk_queue_depth_too_high_threshold
  alarm_description   = "Average database disk queue depth is too high, performance may be negatively impacted."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok
  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  tags = local.module_tags
}

module "disk_free_storage_space_too_low" {
  count = var.create_low_disk_space_alarm ? 1 : 0

  source  = "app.terraform.io/pgetech/cloudwatch/aws"
  version = "0.1.3"

  alarm_name          = "rds-${var.db_instance_id}-lowFreeStorageSpace"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "FreeStorageSpace"
  namespace           = local.namespace
  period              = var.statistic_period
  statistic           = local.statistic
  threshold           = var.disk_free_storage_space_too_low_threshold
  alarm_description   = "Average database free storage space is too low and may fill up soon."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  tags = local.module_tags
}

module "disk_burst_balance_too_low" {
  count = var.create_low_disk_burst_alarm ? 1 : 0

  source  = "app.terraform.io/pgetech/cloudwatch/aws"
  version = "0.1.3"

  alarm_name          = "rds-${var.db_instance_id}-lowEBSBurstBalance"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "BurstBalance"
  namespace           = local.namespace
  period              = var.statistic_period
  statistic           = local.statistic
  threshold           = var.disk_burst_balance_too_low_threshold
  alarm_description   = "Average database storage burst balance is too low, a negative performance impact is imminent."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  tags = local.module_tags
}

# Memory Utilization
module "memory_freeable_too_low" {
  count = var.create_low_memory_alarm ? 1 : 0

  source  = "app.terraform.io/pgetech/cloudwatch/aws"
  version = "0.1.3"

  alarm_name          = "rds-${var.db_instance_id}-lowFreeableMemory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "FreeableMemory"
  namespace           = local.namespace
  period              = var.statistic_period
  statistic           = local.statistic
  threshold           = var.memory_freeable_too_low_threshold
  alarm_description   = "Average database freeable memory is too low, performance may be negatively impacted."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  tags = local.module_tags
}

module "memory_swap_usage_too_high" {
  count = var.create_swap_alarm ? 1 : 0

  source  = "app.terraform.io/pgetech/cloudwatch/aws"
  version = "0.1.3"

  alarm_name          = "rds-${var.db_instance_id}-highSwapUsage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "SwapUsage"
  namespace           = local.namespace
  period              = var.statistic_period
  statistic           = local.statistic
  threshold           = var.memory_swap_usage_too_high_threshold
  alarm_description   = "Average database swap usage is too high, performance may be negatively impacted."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  tags = local.module_tags
}
# Connection Count
resource "aws_cloudwatch_metric_alarm" "anomalous_connection_count" {
  count = var.create_anomaly_alarm ? 1 : 0

  alarm_name          = "rds-${var.db_instance_id}-anomalousConnectionCount"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = var.evaluation_period
  threshold_metric_id = "e1"
  alarm_description   = "Anomalous database connection count detected. Something unusual is happening."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, ${var.anomaly_band_width})"
    label       = "DatabaseConnections (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "DatabaseConnections"
      namespace   = local.namespace
      period      = var.anomaly_period
      stat        = local.statistic
      unit        = "Count"

      dimensions = {
        DBInstanceIdentifier = var.db_instance_id
      }
    }
  }

  tags = local.module_tags
}
