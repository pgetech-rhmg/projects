output "endpoint_config_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this endpoint configuration."
  value       = module.endpoint_configuration.endpoint_config_arn
}

output "endpoint_config_name" {
  description = "The name of the endpoint configuration."
  value       = module.endpoint_configuration.endpoint_config_name
}

output "endpoint_config_tags" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.endpoint_configuration.endpoint_config_tags
}