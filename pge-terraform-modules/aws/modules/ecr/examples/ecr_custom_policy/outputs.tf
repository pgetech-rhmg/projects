output "ecr_arn" {
  description = "Full ARN of the repository."
  value       = module.ecr.ecr_arn
}

output "ecr_registry_id" {
  description = "The registry ID where the repository was created."
  value       = module.ecr.ecr_registry_id
}

output "ecr_repository_url" {
  description = "The URL of the repository."
  value       = module.ecr.ecr_repository_url
}

output "ecr_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = module.ecr.ecr_tags_all
}

output "ecr_repository_name_repository_policy" {
  description = "The name of the repository."
  value       = module.ecr.ecr_repository_name_repository_policy
}