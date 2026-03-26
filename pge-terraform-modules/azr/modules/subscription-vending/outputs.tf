# Outputs for Azure Subscription Vending module

output "subscription_id" {
  description = "Created subscription ID"
  value       = azapi_resource.subscription.output.properties.subscriptionId
}

output "subscription_name" {
  description = "Created subscription name"
  value       = azapi_resource.subscription.name
}

output "subscription_details" {
  description = "Full subscription details"
  value       = azapi_resource.subscription.output
}