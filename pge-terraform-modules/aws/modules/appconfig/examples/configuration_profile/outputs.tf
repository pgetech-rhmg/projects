output "id" {
  description = "The AppConfig configuration profile ID"
  value       = module.configuration_profile.id
}

output "arn" {
  description = "The AppConfig configuration profile ARN"
  value       = module.configuration_profile.arn
}

output "tags" {
  description = "A list of all tags associated with the resource"
  value       = module.configuration_profile.tags
}
