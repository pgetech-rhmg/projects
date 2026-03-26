/*
 * # Azure Register Provider Module
 * Terraform module which registers Azure Resource Providers in a subscription using azapi
*/
#
#  Filename    : modules/resource-providers/main.tf
#  Date        : 3 Mar 2026
#  Author      : Paul Kelley (p3kk@pge.com)
#  Description : Registers one or more Azure Resource Providers in a subscription using azapi, ensuring required services are available before provisioning dependent resources.
#

terraform {
  required_version = ">= 1.0"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

# Register Azure Resource Providers using azapi
# This ensures all required services are available in the subscription
resource "azapi_resource_action" "register_provider" {
  for_each = toset(var.resource_providers)

  type        = "Microsoft.Resources/subscriptions@2022-12-01"
  resource_id = "/subscriptions/${var.subscription_id}"
  action      = "providers/${each.key}/register"
  method      = "POST"

  response_export_values = ["*"]
}

# Wait for providers to be registered before proceeding
resource "time_sleep" "wait_for_providers" {
  create_duration = "30s"
  depends_on      = [azapi_resource_action.register_provider]
}
