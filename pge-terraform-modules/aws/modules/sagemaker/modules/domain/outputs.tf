output "id" {
  description = "The ID of the Domain."
  value       = aws_sagemaker_domain.domain.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Domain."
  value       = aws_sagemaker_domain.domain.arn
}

output "url" {
  description = "The domain's URL."
  value       = aws_sagemaker_domain.domain.url
}

output "single_sign_on_managed_application_instance_id" {
  description = "The SSO managed application instance ID."
  value       = aws_sagemaker_domain.domain.single_sign_on_managed_application_instance_id
}

output "home_efs_file_system_id" {
  description = "The ID of the Amazon Elastic File System (EFS) managed by this Domain."
  value       = aws_sagemaker_domain.domain.home_efs_file_system_id
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_sagemaker_domain.domain.tags_all
}

output "sagemaker_domain_all" {
  description = "A map of aws sagemaker domain"
  value       = aws_sagemaker_domain.domain
}