output "ecr_arn" {
  description = "Full ARN of the repository."
  value       = aws_ecr_repository.ecr.arn
}

output "ecr_registry_id" {
  description = "The registry ID where the repository was created."
  value       = aws_ecr_repository.ecr.registry_id
}

output "ecr_repository_url" {
  description = "The URL of the repository."
  value       = aws_ecr_repository.ecr.repository_url
}

output "ecr_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = aws_ecr_repository.ecr.tags_all
}

output "ecr_repository_name_lifecycle_policy" {
  description = "The name of the repository."
  value       = var.lifecycle_policy_enable ? aws_ecr_lifecycle_policy.lifecycle_policy[0].repository : null
}

output "ecr_repository_name_repository_policy" {
  description = "The name of the repository."
  value       = aws_ecr_repository_policy.repository_policy.repository
}

output "ecr_all" {
  description = "All attributes of ECR repository"
  value       = aws_ecr_repository.ecr
}