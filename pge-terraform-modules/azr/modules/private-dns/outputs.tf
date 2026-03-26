output "dns_zone_ids" {
  value = {
    for service, zone in azurerm_private_dns_zone.zones : service => zone.id
  }
  description = "Map of service name to DNS zone ID"
}

output "dns_zone_names" {
  value = {
    for service, zone in azurerm_private_dns_zone.zones : service => zone.name
  }
  description = "Map of service name to DNS zone name"
}

output "vnet_link_ids" {
  value = {
    for service, link in azurerm_private_dns_zone_virtual_network_link.links : service => link.id
  }
  description = "Map of service name to VNet link ID"
}
