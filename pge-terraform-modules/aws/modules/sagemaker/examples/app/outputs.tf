output "id" {
  description = "The Amazon Resource Name (ARN) of the app."
  value       = module.app.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the app."
  value       = module.app.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.app.tags_all
}