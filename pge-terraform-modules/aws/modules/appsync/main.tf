/*
* # AWS AppSync module
* # Terraform module which creates graphql_api
* # As confirmed by PG&E only 'AWS_IAM' & 'OPENID_CONNECT' types are allowed 
*/
# Filename     : aws/modules/appsync/main.tf 
# Date         : 29 Sep 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of graphql_api

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

resource "aws_appsync_graphql_api" "graphql_api" {
  authentication_type = var.authentication_type
  name                = var.name
  schema              = var.schema
  xray_enabled        = var.xray_enabled
  tags                = local.module_tags
  visibility          = var.visibility

  #As per SAF rule No:06 all logging needs to be enabled
  log_config {
    cloudwatch_logs_role_arn = var.cloudwatch_logs_role_arn
    field_log_level          = "ALL"
    exclude_verbose_content  = false
  }
  dynamic "openid_connect_config" {
    #Below optional block will run only if value of 'authentication_type' is provided as 'OPENID_CONNECT'
    for_each = var.authentication_type == "OPENID_CONNECT" ? [true] : []
    content {
      issuer    = var.openid_connect_config.issuer
      auth_ttl  = var.openid_connect_config.auth_ttl
      client_id = var.openid_connect_config.client_id
      iat_ttl   = var.openid_connect_config.iat_ttl
    }
  }
  dynamic "user_pool_config" {
    #Below optional block will run only if value of 'authentication_type' is provided as 'AMAZON_COGNITO_USER_POOLS'
    for_each = var.authentication_type == "AMAZON_COGNITO_USER_POOLS" ? [true] : []
    content {
      default_action      = var.user_pool_config.default_action
      user_pool_id        = var.user_pool_config.user_pool_id
      app_id_client_regex = var.user_pool_config.app_id_client_regex
      aws_region          = var.user_pool_config.user_pool_config_aws_region
    }
  }
  dynamic "lambda_authorizer_config" {
    #Below optional block will run only if value of 'authentication_type' is provided as 'AWS_LAMBDA'
    for_each = var.authentication_type == "AWS_LAMBDA" ? [true] : []
    content {
      authorizer_uri                   = var.lambda_authorizer_config.authorizer_uri
      authorizer_result_ttl_in_seconds = var.lambda_authorizer_config.authorizer_result_ttl_in_seconds
      identity_validation_expression   = var.lambda_authorizer_config.identity_validation_expression
    }
  }
  dynamic "additional_authentication_provider" {
    #The 'additional_authentication_provider' optional block, can iterate multiple times if multiple values are passed for the variable.
    for_each = var.additional_authentication_provider

    content {
      authentication_type = additional_authentication_provider.value.authentication_type

      dynamic "openid_connect_config" {
        #The 'openid_connect_config' optional block, can iterate only once when the end user pass value for the variable 'additional_authentication_provider'.
        for_each = try(additional_authentication_provider.value.openid_connect_config, {}) != {} ? [try(additional_authentication_provider.value.openid_connect_config, {})] : []

        content {
          issuer    = openid_connect_config.value.issuer
          client_id = try(openid_connect_config.value.client_id, null)
          auth_ttl  = try(openid_connect_config.value.auth_ttl, null)
          iat_ttl   = try(openid_connect_config.value.iat_ttl, null)
        }
      }

      dynamic "user_pool_config" {
        #The 'user_pool_config' optional block, can iterate only once when the end user pass value for the variable 'additional_authentication_provider'.
        for_each = try(additional_authentication_provider.value.user_pool_config, {}) != {} ? [try(additional_authentication_provider.value.user_pool_config, {})] : []

        content {
          user_pool_id        = user_pool_config.value.user_pool_id
          app_id_client_regex = try(user_pool_config.value.app_id_client_regex, null)
          aws_region          = try(user_pool_config.value.aws_region, null)
        }
      }
    }
  }
}

#As per SAF rule No:19
resource "aws_wafv2_web_acl_association" "graphql_api_waf" {
  resource_arn = aws_appsync_graphql_api.graphql_api.arn
  web_acl_arn  = var.web_acl_arn
}