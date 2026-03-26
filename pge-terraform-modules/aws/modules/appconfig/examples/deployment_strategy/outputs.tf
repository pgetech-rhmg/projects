output "id" {
  description = "The AppConfig deployment strategy ID"
  value       = module.deployment_strategy.id
}

output "arn" {
  description = "The AppConfig deployment strategy ARN"
  value       = module.deployment_strategy.arn
}

output "tags" {
  description = "A map of all tags assigned to the resource."
  value       = module.deployment_strategy.tags
}
