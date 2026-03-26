output "github_webhook_url" {
  description = "URL of the webhook. This is a sensitive attribute because it may include basic auth credentials"
  value       = github_repository_webhook.github_webhook.url
}

#aws_codepipeline_webhook
output "codepipeline_webhook_id" {
  description = "codepipeline webhook id"
  value       = aws_codepipeline_webhook.codepipeline_webhook.id
}

output "codepipeline_webhook_url" {
  description = "The URL to the webhook"
  value       = aws_codepipeline_webhook.codepipeline_webhook.url

}

output "codepipeline_webhook" {
  description = "Map of codebuild webhook"
  value       = aws_codepipeline_webhook.codepipeline_webhook
}

output "github_webhook" {
  description = "Map of Repository webhook"
  value       = github_repository_webhook.github_webhook
}