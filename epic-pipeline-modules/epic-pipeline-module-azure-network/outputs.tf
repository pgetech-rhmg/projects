output "vnet_id" {
  value       = azurerm_virtual_network.this.id
  description = "Resource ID of the virtual network"
}

output "vnet_name" {
  value       = azurerm_virtual_network.this.name
  description = "Name of the virtual network"
}

output "subnet_ids" {
  value       = { for name, subnet in azurerm_subnet.this : name => subnet.id }
  description = "Map of subnet name => subnet resource ID"
}

output "public_ip_ids" {
  value       = { for name, pip in azurerm_public_ip.this : name => pip.id }
  description = "Map of public IP name => resource ID"
}

output "public_ip_addresses" {
  value       = { for name, pip in azurerm_public_ip.this : name => pip.ip_address }
  description = "Map of public IP name => allocated IP address"
}
