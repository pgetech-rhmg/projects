output "id" {
  description = "The environment_id generatd by AWS"
  value       = aws_appconfig_environment.pge_env.environment_id
}

output "arn" {
  description = "ARN of the AppConfig Environment."
  value       = aws_appconfig_environment.pge_env.arn
}

output "state" {
  description = "State of the environment."
  value       = aws_appconfig_environment.pge_env.state
}

output "tags" {
  description = "A map of all tags assigned to the environment."
  value       = aws_appconfig_environment.pge_env.tags_all
}
