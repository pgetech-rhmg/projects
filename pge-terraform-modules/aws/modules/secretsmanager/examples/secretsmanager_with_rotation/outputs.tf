output "arn" {
  description = "ARN of the secret"
  value       = module.secretsmanager.arn
}

output "rotation_enabled" {
  description = "Whether automatic rotation is enabled for this secret"
  value       = module.secretsmanager.rotation_enabled
}

output "secret_version_enabled" {
  description = "The version of the secret"
  value       = var.secret_version_enabled
}