output "model_package_group_id" {
  description = "The name of the Model Package Group."
  value       = aws_sagemaker_model_package_group.model_package_group.id
}

output "model_package_group_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Model Package Group."
  value       = aws_sagemaker_model_package_group.model_package_group.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_sagemaker_model_package_group.model_package_group.tags_all
}

output "sagemaker_model_package_group_all" {
  description = "A map of aws sagemaker model package group"
  value       = aws_sagemaker_model_package_group.model_package_group
}