# Outputs for dms source endpoint

output "dms_source_endpoint_arn" {
  description = "ARN for the endpoint."
  value       = aws_dms_endpoint.dms_source_endpoint.endpoint_arn
}

output "dms_source_endpoint_tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_dms_endpoint.dms_source_endpoint.tags_all
}

# Outputs for dms target endpoint

output "dms_target_endpoint_arn" {
  description = "ARN for the endpoint."
  value       = aws_dms_endpoint.dms_target_endpoint.endpoint_arn
}

output "dms_target_endpoint_tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_dms_endpoint.dms_target_endpoint.tags_all
}

output "dms_source_endpoint_all" {
  description = "A map of aws dms source endpoint"
  value       = aws_dms_endpoint.dms_source_endpoint

}

output "dms_target_endpoint_all" {
  description = "A map of aws dms target endpoint"
  value       = aws_dms_endpoint.dms_target_endpoint
}