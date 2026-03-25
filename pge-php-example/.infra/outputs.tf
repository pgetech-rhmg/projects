output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.this.name
}

output "app_service_name" {
  description = "App Service name"
  value       = module.app_service.app_service_name
}

output "default_hostname" {
  description = "App Service default hostname"
  value       = module.app_service.default_hostname
}

output "service_plan_id" {
  description = "App Service Plan ID"
  value       = module.app_service.service_plan_id
}
