output "lifecycle_configuration_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this lifecycle configuration."
  value       = module.lifecycle_configuration.lifecycle_configuration_arn
}