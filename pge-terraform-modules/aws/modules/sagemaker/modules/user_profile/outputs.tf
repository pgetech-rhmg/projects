output "id" {
  description = "The user profile Amazon Resource Name (ARN)."
  value       = aws_sagemaker_user_profile.user_profile.id
}

output "arn" {
  description = "The user profile Amazon Resource Name (ARN)."
  value       = aws_sagemaker_user_profile.user_profile.arn
}

output "home_efs_file_system_id" {
  description = "The ID of the user's profile in the Amazon Elastic File System (EFS) volume."
  value       = aws_sagemaker_user_profile.user_profile.home_efs_file_system_uid
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_sagemaker_user_profile.user_profile.tags_all
}

output "sagemaker_user_profile_all" {
  description = "A map of aws sagemaker user profile"
  value       = aws_sagemaker_user_profile.user_profile
}