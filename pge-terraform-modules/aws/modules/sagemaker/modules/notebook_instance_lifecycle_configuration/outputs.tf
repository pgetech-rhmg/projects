output "lifecycle_configuration_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this lifecycle configuration."
  value       = aws_sagemaker_notebook_instance_lifecycle_configuration.lifecycle_configuration.arn
}

output "sagemaker_notebook_instance_lifecycle_configuration_all" {
  description = "A map of aws sagemaker notebook instance lifecycle configuration"
  value       = aws_sagemaker_notebook_instance_lifecycle_configuration.lifecycle_configuration
}