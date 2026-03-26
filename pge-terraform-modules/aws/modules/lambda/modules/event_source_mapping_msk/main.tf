/*
 * # AWS Lambda event source mapping using Msk
 * Terraform module which creates SAF2.0 Lambda event source mapping in AWS
*/
#
#  Filename    : aws/modules/lambda/modules/event_source_mapping_msk/main.tf
#  Date        : 24 January 2022
#  Author      : TCS
#  Description : LAMBDA terraform module creates a Lambda event source mapping using msk 
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

resource "aws_lambda_event_source_mapping" "msk_event_source_mapping" {

  batch_size                         = var.batch_size
  enabled                            = var.enabled
  event_source_arn                   = var.event_source_arn
  function_name                      = var.function_name
  maximum_batching_window_in_seconds = var.maximum_batching_window_in_seconds
  starting_position                  = var.starting_position
  topics                             = var.topics

  dynamic "source_access_configuration" {
    for_each = var.source_access_configuration
    content {
      type = var.source_access_configuration.type
      uri  = var.source_access_configuration.uri
    }
  }
}

