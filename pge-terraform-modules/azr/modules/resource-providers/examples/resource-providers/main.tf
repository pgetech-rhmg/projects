/*
 * # Azure Register Provider Module
 * Terraform module example which registers Azure Resource Providers in a subscription using azapi
*/
#
#  Filename    : modules/resource-providers/examples/resource-providers/main.tf
#  Date        : 3 Mar 2026
#  Author      : Paul Kelley (p3kk@pge.com)
#  Description : Example of registering one or more Azure Resource Providers in a subscription using azapi, ensuring required services are available before provisioning dependent resources.
#

# Register Azure Resource Providers using azapi
# This ensures all required services are available in the subscription
module "example_resource_provider" {
  source             = "../../"
  subscription_id    = var.subscription_id
  resource_providers = var.resource_providers

}
