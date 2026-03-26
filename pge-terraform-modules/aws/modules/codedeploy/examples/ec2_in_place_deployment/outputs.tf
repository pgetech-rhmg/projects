#outputs for codedeploy_app_ec2
output "codedeploy_app_arn" {
  value       = module.codedeploy_app_ec2.codedeploy_app_arn
  description = "The ARN of the CodeDeploy application."
}

output "codedeploy_app_application_id" {
  value       = module.codedeploy_app_ec2.codedeploy_app_application_id
  description = "The application ID."
}

output "codedeploy_app_id" {
  value       = module.codedeploy_app_ec2.codedeploy_app_id
  description = "Amazon's assigned ID for the application."
}

output "codedeploy_app_name" {
  value       = module.codedeploy_app_ec2.codedeploy_app_name
  description = "The application's name."
}

output "codedeploy_app_github_account_name" {
  value       = module.codedeploy_app_ec2.codedeploy_app_github_account_name
  description = "The name for a connection to a GitHub account."
}

output "codedeploy_app_linked_to_github" {
  value       = module.codedeploy_app_ec2.codedeploy_app_linked_to_github
  description = "Whether the user has authenticated with GitHub for the specified application."
}

output "codedeploy_app_tags_all" {
  value       = module.codedeploy_app_ec2.codedeploy_app_tags_all
  description = "A map of tags assigned to the resource."
}

#outputs for deployment_config_ec2
output "deployment_group_config_name" {
  value       = module.deployment_config_ec2.deployment_group_config_name
  description = "The deployment group's config name."
}

output "deployment_config_id" {
  value       = module.deployment_config_ec2.deployment_config_id
  description = "The AWS Assigned deployment config id."
}

#outputs for deployment_group
output "deployment_group_arn" {
  value       = module.deployment_group.deployment_group_arn
  description = "The ARN of the CodeDeploy deployment group."
}

output "deployment_group_name" {
  value       = module.deployment_group.deployment_group_name
  description = "Application name and deployment group name."
}

output "deployment_group_compute_platform" {
  value       = module.deployment_group.deployment_group_compute_platform
  description = "The destination platform type for the deployment."
}

output "deployment_group_id" {
  value       = module.deployment_group.deployment_group_id
  description = "The ARN of the CodeDeploy deployment group."
}

output "deployment_group_tags_all" {
  value       = module.deployment_group.deployment_group_tags_all
  description = "A map of tags assigned to the resource."
}