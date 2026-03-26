# Outputs for Amplify App

output "amplify_app_arn" {
  description = "ARN of the Amplify app."
  value       = module.amplify_app.arn
}

output "amplify_app_default_domain" {
  description = "Default domain for the Amplify app."
  value       = module.amplify_app.default_domain
}

output "amplify_app_id" {
  description = "Unique ID of the Amplify app."
  value       = module.amplify_app.id
}

output "amplify_app_production_branch" {
  description = "Describes the information about a production branch for an Amplify app."
  value       = module.amplify_app.production_branch
}

output "amplify_app_tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.amplify_app.tags_all
}