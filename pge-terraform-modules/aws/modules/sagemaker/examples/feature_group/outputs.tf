#outputs for feature group

output "name" {
  description = "The name of the Feature Group."
  value       = module.feature_group.name
}

output "arn" {
  description = " The Amazon Resource Name (ARN) assigned by AWS to this feature_group."
  value       = module.feature_group.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.feature_group.tags_all
}