#Outputs for record
output "name" {
  description = "The name of the record."
  value       = module.records.name
}

output "fqdn" {
  description = "FQDN built using the zone domain and name."
  value       = module.records.fqdn
}

output "zone_id" {
  description = "Zone id of the route 53 hosted zone."
  value       = var.zone_id
}

output "name_of_records_with_policy" {
  description = "The name of the record."
  value       = module.records_with_policy.name
}

output "fqdn_records_with_policy" {
  description = "FQDN built using the zone domain and name."
  value       = module.records_with_policy.fqdn
}