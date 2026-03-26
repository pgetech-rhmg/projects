/*
 * # AWS Lambda event source mapping using DynamoDB
 * Terraform module which creates SAF2.0 Lambda event source mapping in AWS
*/
#
#  Filename    : aws/modules/lambda/modules/event_source_mapping_dynamodb/main.tf
#  Date        : 24 January 2022
#  Author      : TCS
#  Description : LAMBDA terraform module creates a Lambda event source mapping using DynamoDB 
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

resource "aws_lambda_event_source_mapping" "dynamodb_event_source_mapping" {

  batch_size                     = var.batch_size
  bisect_batch_on_function_error = var.bisect_batch_on_function_error
  enabled                        = var.enabled
  event_source_arn               = var.event_source_arn
  function_name                  = var.function_name
  function_response_types        = var.function_response_types

  maximum_batching_window_in_seconds = var.maximum_batching_window_in_seconds
  maximum_record_age_in_seconds      = var.maximum_record_age_in_seconds
  maximum_retry_attempts             = var.maximum_retry_attempts

  parallelization_factor     = var.parallelization_factor
  starting_position          = var.starting_position
  tumbling_window_in_seconds = var.tumbling_window_in_seconds

  dynamic "destination_config" {
    for_each = var.destination_arn_on_failure
    content {
      on_failure {
        destination_arn = destination_config.value.destination_arn
      }
    }
  }

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