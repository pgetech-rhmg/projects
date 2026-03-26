/*
* # AWS Sagemaker module
* # Terraform module which creates Sagemaker Workteam
*/
# Filename     : aws/modules/sagemaker/modules/workteam/main.tf 
# Date         : 14 Sep 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of Sagemaker Workteam

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
}

locals {
  namespace = "ccoe-tf-developers"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



resource "aws_sagemaker_workteam" "workteam" {
  workteam_name  = var.workteam_name
  workforce_name = var.workforce_name
  description    = coalesce(var.description, format("%s sagemaker workteam", var.workteam_name))

  member_definition {
    # cognito_member_definition conflicts with oidc_member_definition so the for_each condition looks for value of cognito_member_definition and execute the below dynamic block.
    # Using "{}" instead of "null" in for_each due the given key does not identify an element in this collection value.
    dynamic "cognito_member_definition" {
      for_each = var.member_definition.cognito_member_definition != {} ? [var.member_definition.cognito_member_definition] : []
      content {
        client_id  = cognito_member_definition.value.client_id
        user_pool  = cognito_member_definition.value.user_pool
        user_group = cognito_member_definition.value.user_group
      }
    }

    # oidc_member_definition conflicts with cognito_member_definition so the for_each condition looks for value of oidc_member_definition and executes the below dynamic block.
    # Using "{}" instead of "null" in for_each due the given key does not identify an element in this collection value.
    dynamic "oidc_member_definition" {
      for_each = var.member_definition.oidc_member_definition != {} ? [var.member_definition.oidc_member_definition] : []
      content {
        groups = oidc_member_definition.value.groups
      }
    }
  }

  # The 'notification_configuration' dynamic block is optional and execute only once. Below optional block will run only if
  # value of 'notification_configuration' is provided. The variable 'notification_configuration' is a map
  # so the end user can pass the value in key-value pairs from the example.
  dynamic "notification_configuration" {
    for_each = var.notification_configuration != null ? [var.notification_configuration] : []
    content {
      notification_topic_arn = notification_configuration.value.notification_topic_arn
    }
  }

  tags = local.module_tags
}