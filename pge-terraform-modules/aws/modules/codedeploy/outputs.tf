output "codedeploy_app_arn" {
  value       = aws_codedeploy_app.codedeploy_app.arn
  description = "The ARN of the CodeDeploy application."
}

output "codedeploy_app_application_id" {
  value       = aws_codedeploy_app.codedeploy_app.application_id
  description = "The application ID."
}

output "codedeploy_app_id" {
  value       = aws_codedeploy_app.codedeploy_app.id
  description = "Amazon's assigned ID for the application."
}

output "codedeploy_app_name" {
  value       = aws_codedeploy_app.codedeploy_app.name
  description = "The application's name."
}

output "codedeploy_app_github_account_name" {
  value       = aws_codedeploy_app.codedeploy_app.github_account_name
  description = "The name for a connection to a GitHub account."
}

output "codedeploy_app_linked_to_github" {
  value       = aws_codedeploy_app.codedeploy_app.linked_to_github
  description = "Whether the user has authenticated with GitHub for the specified application."
}

output "codedeploy_app_tags_all" {
  value       = aws_codedeploy_app.codedeploy_app.tags_all
  description = "A map of tags assigned to the resource."
}

output "codedeploy_app" {
  description = "Map of codedeploy app."
  value       = aws_codedeploy_app.codedeploy_app

}