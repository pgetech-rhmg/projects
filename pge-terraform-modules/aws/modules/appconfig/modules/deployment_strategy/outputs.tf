output "id" {
  description = "AppConfig Deployment Strategy ID"
  value       = aws_appconfig_deployment_strategy.pge_strategy.id
}

output "arn" {
  description = "ARN of the APpConfig Deployment Strategy"
  value       = aws_appconfig_deployment_strategy.pge_strategy.arn
}

output "tags" {
  description = "A map of all tags assigned to the resource."
  value       = aws_appconfig_deployment_strategy.pge_strategy.tags_all
}
