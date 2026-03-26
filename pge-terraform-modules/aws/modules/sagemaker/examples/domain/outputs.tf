output "domain_id" {
  description = "The ID of the Domain."
  value       = module.domain.id
}

output "domain_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Domain."
  value       = module.domain.arn
}

output "domain_url" {
  description = "The domain's URL."
  value       = module.domain.url
}

output "domain_single_sign_on_managed_application_instance_id" {
  description = "The SSO managed application instance ID."
  value       = module.domain.single_sign_on_managed_application_instance_id
}

output "domain_home_efs_file_system_id" {
  description = "The ID of the Amazon Elastic File System (EFS) managed by this Domain."
  value       = module.domain.home_efs_file_system_id
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.domain.tags_all
}