output "id" {
  description = "AppConfig Extension ID"
  value       = module.extension.id
}

output "arn" {
  description = "AppConfig Extension ARN"
  value       = module.extension.arn
}

output "version" {
  description = "The version number for the extension."
  value       = module.extension.version
}
