output "repository_webhook_url" {
  description = "URL of the webhook. This is a sensitive attribute because it may include basic auth credentials"
  value       = github_repository_webhook.repository_webhook.url
}

#aws_codebuild_webhook
output "codebuild_webhook_id" {
  description = "The name of the build project"
  value       = aws_codebuild_webhook.codebuild_webhook.id
}

output "codebuild_webhook_payload_url" {
  description = "The CodeBuild endpoint where webhook events are sent"
  value       = aws_codebuild_webhook.codebuild_webhook.payload_url
}

output "codebuild_webhook_secret" {
  description = "The secret token of the associated repository. Not returned by the CodeBuild API for all source types"
  value       = aws_codebuild_webhook.codebuild_webhook.secret
}

output "codebuild_webhook_url" {
  description = "The URL to the webhook"
  value       = aws_codebuild_webhook.codebuild_webhook.url

}

output "codebuild_webhook" {
  description = "Map of codebuild webhook"
  value       = aws_codebuild_webhook.codebuild_webhook
}

output "repository_webhook" {
  description = "Map of Repository webhook"
  value       = github_repository_webhook.repository_webhook
}