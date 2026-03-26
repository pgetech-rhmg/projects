output "id" {
  description = "AppConfig Application ID, Environment ID, and deployment number separated by a slash."
  value       = aws_appconfig_deployment.pge_deployment.id
}

output "arn" {
  description = "ARN of the AppConfig Deployment."
  value       = aws_appconfig_deployment.pge_deployment.arn
}

output "number" {
  description = "The deployment number"
  value       = aws_appconfig_deployment.pge_deployment.deployment_number
}

output "key_arn" {
  description = "ARN of the KMS key used to encrypt the configuration data."
  value       = aws_appconfig_deployment.pge_deployment.kms_key_arn
}

output "state" {
  description = "State of the deployment."
  value       = aws_appconfig_deployment.pge_deployment.state
}

output "tags" {
  description = "A map of tags assigned to the resource."
  value       = aws_appconfig_deployment.pge_deployment.tags_all
}
