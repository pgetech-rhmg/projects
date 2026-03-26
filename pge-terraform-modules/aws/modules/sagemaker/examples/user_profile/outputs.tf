output "user_profile_id" {
  description = "The user profile Amazon Resource Name (ARN)."
  value       = module.user_profile.id
}

output "user_profile_arn" {
  description = "The user profile Amazon Resource Name (ARN)."
  value       = module.user_profile.arn
}

output "user_profile_home_efs_file_system_id" {
  description = "The ID of the user's profile in the Amazon Elastic File System (EFS) volume."
  value       = module.user_profile.home_efs_file_system_id
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.user_profile.tags_all
}