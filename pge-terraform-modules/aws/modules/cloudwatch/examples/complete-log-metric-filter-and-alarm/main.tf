#
# Filename    : aws/usage/complete-log-metric-filter-and-alarm
#  Date        : 17 Nov 2021
#  Author      : PGE
#  Description : multiple cloudwatch log-group and metricalarm creation example
#

locals {
  AppID                         = var.AppID
  Environment                   = var.Environment
  DataClassification            = var.DataClassification
  CRIS                          = var.CRIS
  Notify                        = var.Notify
  Owner                         = var.Owner
  Compliance                    = var.Compliance
  Order                         = var.Order
  MetricTransformationName      = var.MetricTransformationName
  MetricTransformationNamespace = var.MetricTransformationNamespace

  LogGroupNamePrefix      = var.LogGroupNamePrefix
  AlarmDescription        = var.AlarmDescription
  AlarmComparisonOperator = var.AlarmComparisonOperator
  AlarmEvaluationPeriods  = var.AlarmEvaluationPeriods
  AlarmThreshold          = var.AlarmThreshold
  AlarmPeriod             = var.AlarmPeriod
  AlarmUnit               = var.AlarmUnit
  AlarmStatistic          = var.AlarmStatistic
  LogMetricFilterPattern  = var.LogMetricFilterPattern
}

# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms klkey
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.1"
#  name        = var.kms_name
#  description = var.kms_description
#  tags        = module.tags.tags
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
#}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

resource "random_pet" "this" {
  length = 2
}

resource "aws_sns_topic" "this" {
  name = "fixtures-${random_pet.this.id}"
  tags = module.tags.tags
}

#########################################
# Create log_group
#########################################

module "log_group" {
  source = "../../modules/log-group"

  name_prefix = local.LogGroupNamePrefix
  tags        = module.tags.tags
  kms_key_id  = null # replace with module.kms_key.key_arn, after key creation
}

#########################################
# Create log_metric_filter
#########################################

module "log_metric_filter" {
  source = "../../modules/log-metric-filter"

  log_group_name = module.log_group.cloudwatch_log_group_name

  name    = "metric-${module.log_group.cloudwatch_log_group_name}"
  pattern = local.LogMetricFilterPattern

  metric_transformation_namespace = local.MetricTransformationNamespace
  metric_transformation_name      = local.MetricTransformationName
}

#########################################
# Create alarm
#########################################

module "alarm" {
  source = "../../"

  alarm_name          = "log-errors-${module.log_group.cloudwatch_log_group_name}"
  alarm_description   = local.AlarmDescription
  comparison_operator = local.AlarmComparisonOperator
  evaluation_periods  = local.AlarmEvaluationPeriods
  threshold           = local.AlarmThreshold
  period              = local.AlarmPeriod
  unit                = local.AlarmUnit

  namespace   = local.MetricTransformationNamespace
  metric_name = local.MetricTransformationName
  statistic   = local.AlarmStatistic

  alarm_actions = [aws_sns_topic.this.arn]
  tags          = module.tags.tags
}

#########################################
# Creating an alarm based on anomaly detection
#########################################

module "alarm_metric_query_anomalous" {
  source = "../../modules/metric-alarm-anomalous"

  alarm_name          = "terraform-test-foobar"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  comparison_operator = "GreaterThanUpperThreshold"
  datapoints_to_alarm = 2
  evaluation_periods  = 3
  threshold_metric_id = "e1"

  metric_query = [{

    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "CPUUtilization (Expected)"
    return_data = "true"

    }, {
    id          = "m1"
    return_data = "true"
    metric = [{
      namespace   = "AWS/EC2"
      metric_name = "CPUUtilization"
      period      = 120
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        InstanceId = "i-abc123"
      }
    }]
  }]

  tags = module.tags.tags
}

module "alarm_metric_query_anomalous_minimal" {
  source = "../../modules/metric-alarm-anomalous"

  alarm_name          = "terraform-test-minimal"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 1
  threshold_metric_id = "e1"

  metric_query = [{

    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "CPUUtilization (Expected)"
    return_data = "true"

    }, {
    id          = "m1"
    return_data = "true"
    metric = [{
      namespace   = "AWS/EC2"
      metric_name = "CPUUtilization"
      period      = 120
      stat        = "Average"
      dimensions = {
        InstanceId = "i-abc123"
      }
    }]
  }]

  tags = module.tags.tags
}
