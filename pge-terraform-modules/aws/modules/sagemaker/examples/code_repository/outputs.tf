output "id" {
  description = "The name of the Code Repository."
  value       = module.code_repository.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Code Repository."
  value       = module.code_repository.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.code_repository.tags_all
}