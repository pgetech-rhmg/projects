/*
* # AWS AppSync module
* # Terraform module which creates AppSync Datasource.
*/
# Filename     : aws/modules/appsync/modules/datasource/main.tf 
# Date         : 6 October 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of datasource

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


resource "aws_appsync_datasource" "datasource" {
  api_id           = var.api_id
  name             = var.name
  type             = var.config.type
  description      = coalesce(var.description, format("%s datasource - Managed by Terraform", var.name))
  service_role_arn = var.service_role_arn

  dynamic "dynamodb_config" {
    #dynamodb_config is optional so this block will execute once only when user provides the reqired input,otherwise it will be disabled.
    for_each = var.config.dynamodb_config != null ? [var.config.dynamodb_config] : []
    content {
      table_name             = var.config.dynamodb_config.table_name
      region                 = var.config.dynamodb_config.region
      use_caller_credentials = var.config.dynamodb_config.use_caller_credentials
      versioned              = var.config.dynamodb_config.versioned
    }
  }

  dynamic "elasticsearch_config" {
    #elasticsearch_config is optional so this block will execute once only when user provides the reqired input,otherwise it will be disabled.
    for_each = var.config.elasticsearch_config != null ? [var.config.elasticsearch_config] : []
    content {
      endpoint = var.config.elasticsearch_config.endpoint
      region   = var.config.elasticsearch_config.region
    }
  }

  dynamic "http_config" {
    #http_config is optional so this block will execute once only when user provides the reqired input,otherwise it will be disabled.
    for_each = var.config.http_config != null ? [var.config.http_config] : []
    content {
      endpoint = var.config.http_config.endpoint
      dynamic "authorization_config" {
        for_each = var.config.http_config.authentication_type != null ? [true] : []
        content {
          authorization_type = var.config.http_config.authentication_type
          dynamic "aws_iam_config" {
            for_each = var.config.http_config.signing_region != null && var.config.http_config.signing_service_name != null ? [true] : []
            content {
              signing_region       = var.config.http_config.signing_region
              signing_service_name = var.config.http_config.signing_service_name
            }
          }
        }
      }
    }
  }

  dynamic "lambda_config" {
    #lambda_config is optional so this block will execute once only when user provides the reqired input,otherwise it will be disabled.
    for_each = var.config.lambda_config != null ? [var.config.lambda_config] : []
    content {
      function_arn = var.config.lambda_config.function_arn
    }
  }


  dynamic "relational_database_config" {
    #relational_database_config is optional so this block will execute once only when user provides the reqired input,otherwise it will be disabled.
    # for_each = var.config.relational_database_config.source_type != null ? [var.config.relational_database_config.source_type] : []
    for_each = var.config.relational_database_config != null ? [var.config.relational_database_config] : []
    content {
      source_type = var.config.relational_database_config.source_type
      dynamic "http_endpoint_config" {
        for_each = var.config.http_endpoint_config != null && var.config.http_endpoint_config != null ? [true] : []
        content {
          db_cluster_identifier = var.config.relational_database_config.db_cluster_identifier
          aws_secret_store_arn  = var.config.relational_database_config.aws_secret_store_arn
          database_name         = var.config.relational_database_config.database_name
          region                = var.config.relational_database_config.region
          schema                = var.config.relational_database_config.schema
        }
      }
    }
  }
}