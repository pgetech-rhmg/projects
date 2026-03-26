output "studio_lifecycle_config_id" {
  description = "The name of the Studio Lifecycle Config."
  value       = aws_sagemaker_studio_lifecycle_config.studio_lifecycle_config.id
}

output "studio_lifecycle_config_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Studio Lifecycle Config."
  value       = aws_sagemaker_studio_lifecycle_config.studio_lifecycle_config.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_sagemaker_studio_lifecycle_config.studio_lifecycle_config.tags_all
}

output "sagemaker_studio_lifecycle_config_all" {
  description = "A map of aws sagemaker studio lifecycle config"
  value       = aws_sagemaker_studio_lifecycle_config.studio_lifecycle_config
}