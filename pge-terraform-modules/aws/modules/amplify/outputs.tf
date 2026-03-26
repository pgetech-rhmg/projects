# Outputs for Amplify App

output "arn" {
  description = "ARN of the Amplify app."
  value       = aws_amplify_app.amplify_app.arn
}

output "default_domain" {
  description = "Default domain for the Amplify app."
  value       = aws_amplify_app.amplify_app.default_domain
}

output "id" {
  description = "Unique ID of the Amplify app."
  value       = aws_amplify_app.amplify_app.id
}

output "production_branch" {
  description = "Describes the information about a production branch for an Amplify app."
  value       = aws_amplify_app.amplify_app.production_branch
}

output "tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_amplify_app.amplify_app.tags_all
}

output "amplify_app_all" {
  description = "A map of aws amplify app"
  value       = aws_amplify_app.amplify_app
}