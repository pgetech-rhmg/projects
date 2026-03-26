output "endpoint_config_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this endpoint configuration."
  value       = aws_sagemaker_endpoint_configuration.ec.arn
}

output "endpoint_config_name" {
  description = "The name of the endpoint configuration."
  value       = aws_sagemaker_endpoint_configuration.ec.name
}

output "endpoint_config_tags" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_sagemaker_endpoint_configuration.ec.tags_all
}

output "sagemaker_endpoint_configuration_all" {
  description = "A map of aws sagemaker endpoint configuration"
  value       = aws_sagemaker_endpoint_configuration.ec
}