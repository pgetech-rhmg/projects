/*
 * # Azure Observability module
 * Terraform module which creates Log Analytics Workspace in Azure.
 * This module provisions a centralized logging and monitoring solution for Azure resources.
*/

#
# Filename    : azr/modules/observability/main.tf
# Date        : 12 Mar 2026
# Author      : PGE
# Description : Azure Observability module for Log Analytics Workspace
#

# Module      : Log Analytics Workspace
# Description : This terraform module creates a Log Analytics Workspace using azapi_resource.

resource "azapi_resource" "law" {
  type      = "Microsoft.OperationalInsights/workspaces@2023-09-01"
  name      = "law-${var.partner_name}-${var.partner_config.environment}"
  location  = var.location
  parent_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"

  body = {
    properties = {
      sku = {
        name = "PerGB2018"
      }
      retentionInDays = var.retention_days
    }
  }

  tags = var.tags

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# Enable solutions for common monitoring scenarios
# Note: Solutions can be enabled via Azure Portal or additional azapi_resource calls
# Supported: SecurityInsights, ContainerInsights, VMInsights, AzureActivity, ChangeTracking, Updates, Security

# Diagnostic settings for common resources (example)
# These would be applied to specific resources in actual implementation
