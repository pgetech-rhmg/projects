/*
 * # AWS Cloudwatch module
 * Terraform module which creates SAF2.0 Cloudwatch Log metric filter resource in AWS.
*/
#
#  Filename    : modules/cloudwatch/log-metric-filter/main.tf
#  Date        : 17 Nov 2021
#  Author      : PGE
#  Description : Creates CloudWatch Log Metric Filter resource.
#

terraform {
  required_version = ">= 1.0.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_cloudwatch_log_metric_filter" "this" {
  name           = var.name
  pattern        = var.pattern
  log_group_name = var.log_group_name

  metric_transformation {
    name          = var.metric_transformation_name
    namespace     = var.metric_transformation_namespace
    value         = var.metric_transformation_value
    default_value = var.metric_transformation_default_value
  }
}
