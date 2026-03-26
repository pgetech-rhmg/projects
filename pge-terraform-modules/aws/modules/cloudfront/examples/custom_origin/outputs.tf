# #aws_cloudfront_distribution
output "cloudfront_distribution_id" {
  description = "The identifier for the distribution."
  value       = module.cloudfront.cloudfront_distribution_id
}

output "cloudfront_distribution_arn" {
  description = "The ARN (Amazon Resource Name) for the distribution."
  value       = module.cloudfront.cloudfront_distribution_arn
}

output "cloudfront_distribution_caller_reference" {
  description = "Internal value used by CloudFront to allow future updates to the distribution configuration."
  value       = module.cloudfront.cloudfront_distribution_caller_reference
}

output "cloudfront_distribution_status" {
  description = "The current status of the distribution. Deployed if the distribution's information is fully propagated throughout the Amazon CloudFront system."
  value       = module.cloudfront.cloudfront_distribution_status
}

output "cloudfront_distribution_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider."
  value       = module.cloudfront.cloudfront_distribution_tags_all
}

output "cloudfront_distribution_trusted_key_groups" {
  description = "List of nested attributes for active trusted key groups, if the distribution is set up to serve private content with signed URLs."
  value       = module.cloudfront.cloudfront_distribution_trusted_key_groups
}

output "cloudfront_distribution_trusted_signers" {
  description = "List of nested attributes for active trusted signers, if the distribution is set up to serve private content with signed URLs."
  value       = module.cloudfront.cloudfront_distribution_trusted_signers
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to the distribution."
  value       = module.cloudfront.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_last_modified_time" {
  description = "The date and time the distribution was last modified."
  value       = module.cloudfront.cloudfront_distribution_last_modified_time
}

output "cloudfront_distribution_in_progress_validation_batches" {
  description = "The number of invalidation batches currently in progress."
  value       = module.cloudfront.cloudfront_distribution_in_progress_validation_batches
}

output "cloudfront_distribution_etag" {
  description = "The current version of the distribution's information."
  value       = module.cloudfront.cloudfront_distribution_etag
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID that can be used to route an Alias Resource Record Set to. This attribute is simply an alias for the zone ID."
  value       = module.cloudfront.cloudfront_distribution_hosted_zone_id
}

# #aws_cloudfront_monitoring_subscription
output "monitoring_subscription_id" {
  description = "The ID of the CloudFront monitoring subscription, which corresponds to the distribution_id."
  value       = module.cloudfront.monitoring_subscription_id
}

# #aws_cloudfront_realtime_log_config
output "realtime_log_config_id" {
  description = "The ID of the CloudFront real-time log configuration."
  value       = module.cloudfront.realtime_log_config_id
}

output "realtime_log_config_arn" {
  description = "The ARN (Amazon Resource Name) of the CloudFront real-time log configuration."
  value       = module.cloudfront.realtime_log_config_arn
}

# #aws_cloudfront_field_level_encryption_config
output "field_level_encryption_config_caller_reference" {
  description = "Internal value used by CloudFront to allow future updates to the Field Level Encryption Config."
  value       = module.encryption_configurations.field_level_encryption_config_caller_reference
}

output "field_level_encryption_config_etag" {
  description = "The current version of the Field Level Encryption Config."
  value       = module.encryption_configurations.field_level_encryption_config_etag
}

output "field_level_encryption_config_id" {
  description = "The identifier for the Field Level Encryption Config."
  value       = module.encryption_configurations.field_level_encryption_config_id
}

# aws_cloudfront_field_level_encryption_profile
output "field_level_encryption_profile_caller_reference" {
  description = "Internal value used by CloudFront to allow future updates to the Field Level Encryption Profile."
  value       = module.encryption_profiles.field_level_encryption_profile_caller_reference
}

output "field_level_encryption_profile_etag" {
  description = "The current version of the Field Level Encryption Profile."
  value       = module.encryption_profiles.field_level_encryption_profile_etag
}

output "field_level_encryption_profile_id" {
  description = "The identifier for the Field Level Encryption Profile."
  value       = module.encryption_profiles.field_level_encryption_profile_id
}

# #aws_cloudfront_key_group
output "key_group_etag" {
  description = " The identifier for this version of the key group."
  value       = module.key_management.key_group_etag
}

output "key_group_id" {
  description = "The identifier for the key group."
  value       = module.key_management.key_group_id
}

# #aws_cloudfront_public_key
output "public_key_caller_reference" {
  description = "Internal value used by CloudFront to allow future updates to the public key configuration."
  value       = module.key_management.public_key_caller_reference
}

output "public_key_etag" {
  description = "The current version of the public key."
  value       = module.key_management.public_key_etag
}

output "public_key_id" {
  description = "The current version of the public key."
  value       = module.key_management.public_key_id
}

# #aws_cloudfront_cache_policy
output "cache_policy_etag" {
  description = "The current version of the cache policy."
  value       = module.cloudfront_policy.cache_policy_etag
}

output "cache_policy_id" {
  description = "The identifier for the cache policy."
  value       = module.cloudfront_policy.cache_policy_id
}

# #aws_cloudfront_response_headers_policy
output "response_headers_policy_etag" {
  description = "The current version of the response headers policy."
  value       = module.cloudfront_policy.response_headers_policy_etag
}

output "response_headers_policy_id" {
  description = "The identifier for the response headers policy."
  value       = module.cloudfront_policy.response_headers_policy_id
}

# #aws_cloudfront_origin_request_policy
output "origin_request_policy_etag" {
  description = "The current version of the origin request policy."
  value       = module.cloudfront_policy.origin_request_policy_etag
}

output "origin_request_policy_id" {
  description = "The identifier for the origin request policy."
  value       = module.cloudfront_policy.origin_request_policy_id
}

# cloudfront_function
output "cloudfront_function_arn" {
  description = "Amazon Resource Name (ARN) identifying your CloudFront Function."
  value       = module.cloudfront_function.cloudfront_function_arn
}

output "cloudfront_function_etag" {
  description = " ETag hash of the function. This is the value for the DEVELOPMENT stage of the function."
  value       = module.cloudfront_function.cloudfront_function_etag
}

output "cloudfront_function_live_stage_etag" {
  description = "ETag hash of any LIVE stage of the function."
  value       = module.cloudfront_function.cloudfront_function_live_stage_etag
}

output "cloudfront_function_status" {
  description = "Status of the function. Can be UNPUBLISHED, UNASSOCIATED or ASSOCIATED."
  value       = module.cloudfront_function.cloudfront_function_status
}

