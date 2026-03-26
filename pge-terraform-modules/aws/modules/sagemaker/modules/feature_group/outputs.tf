#outputs for feature group

output "name" {
  description = "The name of the Feature Group."
  value       = aws_sagemaker_feature_group.feature_group.feature_group_name
}

output "arn" {
  description = " The Amazon Resource Name (ARN) assigned by AWS to this feature_group."
  value       = aws_sagemaker_feature_group.feature_group.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_sagemaker_feature_group.feature_group.tags_all
}

output "sagemaker_feature_group_all" {
  description = "A map of aws sagemaker feature group"
  value       = aws_sagemaker_feature_group.feature_group
}