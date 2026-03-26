output "peering_id" {
  description = "Partner to Hub peering resource ID"
  value       = azapi_resource.partner_to_hub.id
}

output "peering_name" {
  description = "Partner to Hub peering name"
  value       = azapi_resource.partner_to_hub.name
}

output "hub_peering_id" {
  description = "Hub to Partner peering resource ID"
  value       = azapi_resource.hub_to_partner.id
}

output "hub_peering_name" {
  description = "Hub to Partner peering name"
  value       = azapi_resource.hub_to_partner.name
}

output "peering_status" {
  description = "Peering status"
  value = {
    partner_to_hub = "Configured"
    hub_to_partner = "Configured"
  }
}
