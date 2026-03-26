/*
* # AWS AppSync module
* # Terraform module which creates AppSync Resolver
*/
# Filename     : aws/modules/appsync/modules/resolver/main.tf 
# Date         : 7 Oct 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of aws_appsync_resolver

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_appsync_resolver" "appsync_resolver" {
  api_id            = var.api_id
  type              = var.type
  field             = var.field
  request_template  = var.request_template
  response_template = var.response_template
  data_source       = var.data_source
  max_batch_size    = var.max_batch_size
  kind              = var.kind

  #SyncConfig can only be specified when data source type is 'DynamoDB' and versioned is set to 'true'.
  dynamic "sync_config" {
    #The below optional block will execute only when the arguments conflict_detection and conflict_handler have values.
    for_each = var.sync_config.conflict_detection != null && var.sync_config.conflict_handler != null ? [true] : []
    content {
      conflict_detection = var.sync_config.conflict_detection
      conflict_handler   = var.sync_config.conflict_handler
      dynamic "lambda_conflict_handler_config" {
        #Below optional block will run only if value of 'conflict_handler' is 'LAMBDA'.
        for_each = var.sync_config.conflict_handler == "LAMBDA" ? [true] : []
        content {
          lambda_conflict_handler_arn = var.sync_config.lambda_conflict_handler_arn
        }
      }
    }
  }

  dynamic "pipeline_config" {
    for_each = var.pipeline_config != null ? [var.pipeline_config] : []
    content {
      functions = pipeline_config.value.functions
    }
  }

  dynamic "caching_config" {
    for_each = var.caching_keys != null ? [true] : []
    content {
      caching_keys = var.caching_keys
      ttl          = var.ttl
    }
  }
}