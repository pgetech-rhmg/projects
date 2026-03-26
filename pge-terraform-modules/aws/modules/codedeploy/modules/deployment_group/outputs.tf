output "deployment_group_arn" {
  value       = aws_codedeploy_deployment_group.deployment_group.arn
  description = "The ARN of the CodeDeploy deployment group."
}

output "deployment_group_name" {
  value       = aws_codedeploy_deployment_group.deployment_group.deployment_group_name
  description = "Application name and deployment group name."
}

output "deployment_group_compute_platform" {
  value       = aws_codedeploy_deployment_group.deployment_group.compute_platform
  description = "The destination platform type for the deployment."
}

output "deployment_group_id" {
  value       = aws_codedeploy_deployment_group.deployment_group.deployment_group_id
  description = "The ARN of the CodeDeploy deployment group."
}

output "deployment_group_tags_all" {
  value       = aws_codedeploy_deployment_group.deployment_group.tags_all
  description = "A map of tags assigned to the resource."
}

output "codedeploy_deployment_group" {
  description = "Map of codedeploy deployment group."
  value       = aws_codedeploy_deployment_group.deployment_group
}