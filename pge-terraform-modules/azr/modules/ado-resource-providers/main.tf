/*
 * # Azure DevOps Resource Providers Module
 * Terraform module which registers required Azure Resource Providers for Azure DevOps automation using azapi
*/
#
#  Filename    : modules/ado-resource-providers/main.tf
#  Date        : 09 Mar 2026
#  Author      : PGE
#  Description : Registers Microsoft.DevCenter and Microsoft.DevOpsInfrastructure providers in a subscription using azapi, ensuring Azure DevOps automation services are available for host build pools and managed build agents.
#

terraform {
  required_version = ">= 1.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
  }
}

# Register required Azure resource providers for ADO automation
# Using azapi to explicitly target the correct subscription
# These providers are needed for:
# - Microsoft.DevCenter: Host build pools
# - Microsoft.DevOpsInfrastructure: Managed build agents

# Register each provider using azapi (allows explicit subscription targeting)
resource "azapi_resource_action" "register_providers" {
  for_each = toset([
    "Microsoft.DevCenter",
    "Microsoft.DevOpsInfrastructure"
  ])

  type        = "Microsoft.Resources/providers@2021-04-01"
  resource_id = "/subscriptions/${var.subscription_id}/providers/${each.key}"
  action      = "register"
  method      = "POST"
}
