# Outputs for dms source endpoint

output "dms_source_endpoint_arn" {
  description = "ARN for the endpoint."
  value       = module.dms_endpoint.dms_source_endpoint_arn
}

output "dms_source_endpoint_tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.dms_endpoint.dms_source_endpoint_tags_all
}

# Outputs for dms target endpoint

output "dms_target_endpoint_arn" {
  description = "ARN for the endpoint."
  value       = module.dms_endpoint.dms_target_endpoint_arn
}

output "dms_target_endpoint_tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.dms_endpoint.dms_target_endpoint_tags_all
}