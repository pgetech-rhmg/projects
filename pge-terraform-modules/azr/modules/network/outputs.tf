output "vnet_id" {
  description = "VNet resource ID"
  value       = azapi_resource.vnet.id
}

output "vnet_name" {
  description = "VNet name"
  value       = azapi_resource.vnet.name
}

output "vnet_address_space" {
  description = "VNet address space"
  value       = azapi_resource.vnet.body.properties.addressSpace.addressPrefixes
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value = {
    "compute-subnet"         = azapi_resource.subnet_0.id
    "privateendpoint-subnet" = azapi_resource.subnet_1.id
    "ado-agents-subnet"      = azapi_resource.subnet_2.id
  }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to address prefixes"
  value = {
    "compute-subnet"         = [azapi_resource.subnet_0.body.properties.addressPrefix]
    "privateendpoint-subnet" = [azapi_resource.subnet_1.body.properties.addressPrefix]
    "ado-agents-subnet"      = [azapi_resource.subnet_2.body.properties.addressPrefix]
  }
}

output "nsg_ids" {
  description = "Map of NSG names to IDs"
  value       = { for k, v in azapi_resource.subnet_nsg : k => v.id }
}

output "dns_servers" {
  description = "Custom DNS servers configured on VNet"
  value       = try(azapi_resource.vnet.body.properties.dhcpOptions.dnsServers, local.dns_servers)
}

output "transit_route_table_id" {
  description = "Transit route table resource ID (for Hub-Palo routing)"
  value       = azapi_resource.transit_route_table.id
}

output "transit_route_table_name" {
  description = "Transit route table name"
  value       = azapi_resource.transit_route_table.name
}
