/*
 * # Azure Subscription Vending module.
 * Terraform module which creates Azure Subscription using Subscription Alias API.
*/

#
# Filename    : azr/modules/subscription-vending/main.tf
# Date        : 25 February 2026
# Author      : PGE
# Description : Azure Subscription Vending module main


terraform {

  required_version = ">= 1.0"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Create subscription using Azure subscription alias API
# Enterprise Agreement (EA) billing model
#
# Will be explaining the same to Sara Ahmad, Balaji, and CCOE team as part of subscription management training.
#  IMPORTANT: Azure subscriptions are NEVER truly deleted!
# When you destroy this resource, Azure only deletes the ALIAS, not the subscription.
# The subscription goes into "Disabled" state and can be reactivated within 90 days.
# Creating a new alias with the same name creates a NEW subscription (different ID).
# This is why you may see "duplicate" subscriptions with the same name but different IDs.
#
# To avoid duplicates:
# 1. Never taint or force-replace this resource
# 2. Import existing subscriptions instead of creating new ones
# 3. Use `terraform state rm` + manual cleanup if needed
#

# Normalize tags - convert array values to comma-separated strings
# Azure subscription tags only support string values, not arrays
locals {
  normalized_tags = {
    for key, value in try(var.partner_config.tags, {}) :
    key => can(tolist(value)) ? join(", ", value) : tostring(value)
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

resource "azapi_resource" "subscription" {
  type      = "Microsoft.Subscription/aliases@2021-10-01"
  name      = "sub-${var.partner_name}-${var.partner_config.environment}"
  parent_id = "/"

  body = {
    properties = {
      displayName  = try(var.partner_config.subscription_name, "${title(var.partner_name)}-${var.partner_config.environment}")
      billingScope = var.billing_scope
      workload     = "Production"

      additionalProperties = {
        managementGroupId    = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
        subscriptionTenantId = data.azurerm_client_config.current.tenant_id
        subscriptionOwnerId  = data.azurerm_client_config.current.object_id
        tags = merge(
          local.normalized_tags, local.module_tags,
          {
            ManagedBy        = "Terraform"
            Environment      = var.partner_config.environment
            Partner          = var.partner_name
            BillingType      = "EA"
            ado_project_name = var.ado_project
          }
        )
      }
    }
  }

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }

  response_export_values = ["properties.subscriptionId"]

  # CRITICAL: Prevent accidental recreation which causes duplicate subscriptions
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      # Ignore tag changes that might trigger recreation
      body["properties"]["additionalProperties"]["tags"]
    ]
  }
}

data "azurerm_client_config" "current" {}

# Move subscription to management group if not already placed
# NOTE: Skipped for now - subscription is already associated with management group
# To enable later:
# 1. Uncomment this resource
# 2. Run: terraform import 'module.subscription_vending["neudesic-ccoe-app"].azurerm_management_group_subscription_association.subscription' '/providers/Microsoft.Management/managementGroups/{mgGroup}/subscriptions/{subId}'
# 3. Or use: ../import_mgmt_group_subscription.sh

# resource "azurerm_management_group_subscription_association" "subscription" {
#   management_group_id = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
#   subscription_id     = "/subscriptions/${azapi_resource.subscription.output.properties.subscriptionId}"
#
#   depends_on = [azapi_resource.subscription]
# }