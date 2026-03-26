output "application_id" {
  description = "The AppConfig application ID"
  value       = module.application.id
}

output "environment_id" {
  description = "The AppConfig environment ID"
  value       = module.environment.id
}

output "configuration_profile_id" {
  description = "The AppConfig configuration profile ID"
  value       = module.configuration_profile.id
}

output "deployment_strategy_id" {
  description = "The AppConfig deployment strategy ID"
  value       = module.deployment_strategy.id
}

output "deployment_id" {
  description = "The AppConfig application ID, environment ID, and deployment number separated by a slash"
  value       = module.deployment.id
}
