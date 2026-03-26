output "service_plan_id" {
  value       = azurerm_service_plan.plan.id
  description = "ID of the App Service Plan"
}

output "service_plan_name" {
  value       = azurerm_service_plan.plan.name
  description = "Name of the App Service Plan"
}

output "sku_name" {
  value       = azurerm_service_plan.plan.sku_name
  description = "SKU name of the plan"
}

output "max_burst_worker_count" {
  value       = try(azurerm_service_plan.plan.maximum_elastic_worker_count, null)
  description = "Maximum elastic worker count"
}
