output "codebuild_project_arn" {
  description = "ARN of the CodeBuild project"
  value       = module.codebuild_project.codebuild_project_arn
}

output "codebuild_project_badge_url" {
  description = "URL of the build badge when badge_enabled is enabled"
  value       = module.codebuild_project.codebuild_project_badge_url
}

output "codebuild_project_id" {
  description = "Name or ARN of the CodeBuild project"
  value       = module.codebuild_project.codebuild_project_id
}

output "codebuild_project_project_alias" {
  description = "The project identifier used with the public build APIs"
  value       = module.codebuild_project.codebuild_project_project_alias
}

output "codebuild_project_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider"
  value       = module.codebuild_project.codebuild_project_tags_all
}

output "codebuild_webhook_payload_url" {
  description = "The CodeBuild endpoint where webhook events are sent"
  value       = module.github_webhook.codebuild_webhook_payload_url
}

output "codebuild_webhook_url" {
  description = "The URL to the webhook"
  value       = module.github_webhook.codebuild_webhook_url
}