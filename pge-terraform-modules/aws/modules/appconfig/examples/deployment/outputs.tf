output "id" {
  description = "The AppConfig application ID, environment ID, and deployment number separated by a slash"
  value       = module.deployment.id
}

output "arn" {
  description = "The AppConfig deployment ARN"
  value       = module.deployment.arn
}

output "number" {
  description = "The AppConfig deployment number"
  value       = module.deployment.number
}

output "key_arn" {
  description = "The ARN of the KMS key used to encrypt the configuration data"
  value       = module.deployment.key_arn
}

output "state" {
  description = "The state of the deployment"
  value       = module.deployment.state
}

output "tags" {
  description = "A map of tags assigned to the resource"
  value       = module.deployment.tags
}
