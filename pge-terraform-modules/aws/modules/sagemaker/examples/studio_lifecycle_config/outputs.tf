output "studio_lifecycle_config_id" {
  description = "The name of the Studio Lifecycle Config."
  value       = module.studio_lifecycle_config.studio_lifecycle_config_id
}

output "studio_lifecycle_config_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Studio Lifecycle Config."
  value       = module.studio_lifecycle_config.studio_lifecycle_config_arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.studio_lifecycle_config.tags_all
}