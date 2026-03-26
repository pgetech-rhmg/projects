output "deployment_group_config_name" {
  value       = aws_codedeploy_deployment_config.deployment_config.deployment_config_name
  description = "The deployment group's config name."
}

output "deployment_config_id" {
  value       = aws_codedeploy_deployment_config.deployment_config.deployment_config_id
  description = "The AWS Assigned deployment config id."
}

output "codedeploy_deployment_config" {
  description = "Map of codedeploy deployment config."
  value       = aws_codedeploy_deployment_config.deployment_config
}