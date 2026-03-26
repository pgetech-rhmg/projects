/*
 * # AWS Lambda event source mapping using sqs
 * Terraform module which creates SAF2.0 Lambda event source mapping in AWS
*/
#
#  Filename    : aws/modules/lambda/modules/event_source_mapping_sqs/main.tf
#  Date        : 24 January 2022
#  Author      : TCS
#  Description : LAMBDA terraform module creates a Lambda event source mapping using sqs
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


resource "aws_lambda_event_source_mapping" "sqs_event_source_mapping" {

  batch_size                         = var.batch_size
  enabled                            = var.enabled
  event_source_arn                   = var.event_source_arn
  function_name                      = var.function_name
  function_response_types            = var.function_response_types
  maximum_batching_window_in_seconds = var.maximum_batching_window_in_seconds


  dynamic "filter_criteria" {
    for_each = var.filter_criteria_pattern

    content {
      dynamic "filter" {
        for_each = filter_criteria.value.filter
        content {
          pattern = filter.value.pattern
        }
      }
    }
  }
}
