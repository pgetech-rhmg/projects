output "id" {
  description = "The name of the App Image Config."
  value       = aws_sagemaker_app_image_config.app_image_config.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this App Image Config."
  value       = aws_sagemaker_app_image_config.app_image_config.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_sagemaker_app_image_config.app_image_config.tags_all
}

output "sagemaker_app_image_config_all" {
  description = "A map of aws sagemaker app image config"
  value       = aws_sagemaker_app_image_config.app_image_config
}