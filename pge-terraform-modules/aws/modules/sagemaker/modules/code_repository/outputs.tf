output "id" {
  description = "The name of the Code Repository."
  value       = aws_sagemaker_code_repository.code_repository.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Code Repository."
  value       = aws_sagemaker_code_repository.code_repository.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_sagemaker_code_repository.code_repository.tags_all
}

output "sagemaker_code_repository_all" {
  description = "A map of aws sagemaker code repository"
  value       = aws_sagemaker_code_repository.code_repository
}