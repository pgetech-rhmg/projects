/*
* # AWS AppSync Module
* # Terraform module which creates AppSync Function
*/
# Filename     : aws/modules/appsync/modules/function/main.tf 
# Date         : 10 Oct 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of AppSync Function

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_appsync_function" "function" {
  name                      = var.name
  api_id                    = var.api_id
  data_source               = var.data_source
  request_mapping_template  = var.request_mapping_template
  response_mapping_template = var.response_mapping_template
  description               = coalesce(var.description, format("%s AppSync Function", var.name))

  #Max_batch_size can only be specified when data source type is 'Lambda'.
  max_batch_size   = var.max_batch_size
  function_version = var.function_version
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
}