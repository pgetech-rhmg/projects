#
# Filename    : azr/modules/app-service-environment/outputs.tf
# Date        : 09 March 2026
# Author      : PGE
# Description : Output values for Azure App Service Environment module
#

output "ase_id" {
  value       = azurerm_app_service_environment_v3.ase.id
  description = "ID of the App Service Environment"
}

output "ase_name" {
  value       = azurerm_app_service_environment_v3.ase.name
  description = "Name of the App Service Environment"
}

output "ase_location" {
  value       = azurerm_app_service_environment_v3.ase.location
  description = "Location of the App Service Environment"
}

output "ase_subnet_id" {
  value       = azurerm_app_service_environment_v3.ase.subnet_id
  description = "Subnet ID of the ASE"
}

output "ase_dns_suffix" {
  value       = try(azurerm_app_service_environment_v3.ase.dns_suffix, "")
  description = "DNS suffix of the ASE"
}

output "ase_internal_ip" {
  value       = try(azurerm_app_service_environment_v3.ase.internal_inbound_ip_addresses, [])
  description = "Internal inbound IP addresses of the ASE"
}

output "private_dns_zone_id" {
  value       = var.create_private_dns_zone && var.internal_load_balancing_mode == "Web, Publishing" ? azurerm_private_dns_zone.ase[0].id : null
  description = "ID of the private DNS zone for the ASE"
}

output "private_dns_zone_name" {
  value       = var.create_private_dns_zone && var.internal_load_balancing_mode == "Web, Publishing" ? azurerm_private_dns_zone.ase[0].name : null
  description = "Name of the private DNS zone for the ASE"
}
