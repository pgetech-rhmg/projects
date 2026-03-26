/*
 * # AWS appstream stack module.
 * Terraform module which creates SAF2.0 Appstream2.0 in AWS.
*/
#  Filename    : aws/modules/appstream2/modules/stack/main.tf
#  Date         : 19 Aug 2022
#  Author      : TCS
#  Description : stack appstream2.0

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : stack Creation
# Description : This terraform module creates a appstream-2.0 stack.

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

resource "aws_appstream_stack" "stack" {
  name               = var.name
  description        = coalesce(var.description, format("%s appstream stack - Managed by Terraform", var.name))
  display_name       = var.display_name
  feedback_url       = var.feedback_url
  redirect_url       = var.redirect_url
  embed_host_domains = var.embed_host_domains

  #As per SAF enable the home folders feature for each AppStream 2.0 stack that you create via the AWS Management Console or the AWS SDK.
  #Dynamic block is used here to iterate over the available arguments for each name and value
  dynamic "storage_connectors" {
    for_each = var.storage_connectors
    content {
      connector_type      = "HOMEFOLDERS"
      domains             = storage_connectors.value.domains
      resource_identifier = storage_connectors.value.resource_identifier
    }
  }

  dynamic "user_settings" {
    for_each = [for ust in var.user_settings : {
      action     = ust.action
      permission = ust.permission
    }]
    content {
      action     = user_settings.value.action
      permission = user_settings.value.permission
    }
  }

  #AppStream 2.0 supports persistent application settings for Windows-based stacks. This means that your users' application customizations and Windows settings are automatically saved after each streaming session and applied during the next session. 
  #Examples of persistent application settings that your users can configure include, but are not limited to, browser favorites, settings, webpage sessions, application connection profiles, plugins, and UI customizations. 
  #These settings are saved to an Amazon Simple Storage Service (Amazon S3) bucket in your account, within the AWS Region in which application settings persistence is enabled. They are available in each AppStream 2.0 streaming session.

  dynamic "application_settings" {
    for_each = var.application_settings
    content {
      enabled        = application_settings.value.enabled
      settings_group = application_settings.value.settings_group
    }
  }

  dynamic "access_endpoints" {
    for_each = var.access_endpoints
    content {
      endpoint_type = access_endpoints.value.endpoint_type
      vpce_id       = access_endpoints.value.vpce_id
    }
  }

  tags = local.module_tags
}