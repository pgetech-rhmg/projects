output "id" {
  description = "The AppConfig application ID, configuration profile ID, and version number separated by a slash."
  value       = module.hosted_configuration_version.id
}

output "arn" {
  description = "The ARN of the AppConfig hosted configuration version."
  value       = module.hosted_configuration_version.arn
}

output "version" {
  description = "Version number of the hosted configuration."
  value       = module.hosted_configuration_version.version
}
