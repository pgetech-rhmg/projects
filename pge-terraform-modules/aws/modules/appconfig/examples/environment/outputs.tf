output "id" {
  description = "The AppConfig environment ID"
  value       = module.environment.id
}

output "arn" {
  description = "The AppCOnfig environment ARN"
  value       = module.environment.arn
}

output "state" {
  description = "State of the environment"
  value       = module.environment.state
}

output "tags" {
  description = "A map of all tags assigned to the resource."
  value       = module.environment.tags
}
