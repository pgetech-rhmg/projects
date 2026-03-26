

################################################

#aws_cloudfront_origin_access_identity
output "origin_access_identity_id" {
  description = "The identifier for the distribution."
  value       = module.cloudfront_oai.origin_access_identity_id
}

output "origin_access_identity_caller_reference" {
  description = "Internal value used by CloudFront to allow future updates to the origin access identity."
  value       = module.cloudfront_oai.origin_access_identity_caller_reference
}

output "origin_access_identity_cloudfront_access_identity_path" {
  description = "A shortcut to the full path for the origin access identity to use in CloudFront."
  value       = module.cloudfront_oai.origin_access_identity_cloudfront_access_identity_path
}

output "origin_access_identity_etag" {
  description = "The current version of the origin access identity's information."
  value       = module.cloudfront_oai.origin_access_identity_etag
}

output "origin_access_identity_iam_arn" {
  description = "A pre-generated ARN for use in S3 bucket policies."
  value       = module.cloudfront_oai.origin_access_identity_iam_arn
}

output "origin_access_identity_s3_canonical_user_id" {
  description = "The Amazon S3 canonical user ID for the origin access identity, which you use when giving the origin access identity read permission to an object in Amazon S3."
  value       = module.cloudfront_oai.origin_access_identity_s3_canonical_user_id
}

#aws_cloudfront_distribution
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

# # #aws_cloudfront_realtime_log_config
output "realtime_log_config_id" {
  description = "The ID of the CloudFront real-time log configuration."
  value       = module.cloudfront.realtime_log_config_id
}

output "realtime_log_config_arn" {
  description = "The ARN (Amazon Resource Name) of the CloudFront real-time log configuration."
  value       = module.cloudfront.realtime_log_config_arn
}


################################################

output "lambda_arn" {
  value       = module.lambda_edge_function.lambda_arn
  description = "Amazon Resource Name (ARN) identifying your Lambda Function"
}

output "lambda_invoke_arn" {
  value       = module.lambda_edge_function.lambda_invoke_arn
  description = "ARN to be used for invoking Lambda Function from API Gateway - to be used in aws_api_gateway_integration's uri"
}

output "lambda_last_modified" {
  value       = module.lambda_edge_function.lambda_last_modified
  description = "Date this resource was last modified"
}

output "lambda_qualified_arn" {
  value       = module.lambda_edge_function.lambda_qualified_arn
  description = "ARN identifying your Lambda Function Version (if versioning is enabled via publish = true)"
}

output "lambda_signing_job_arn" {
  value       = module.lambda_edge_function.lambda_signing_job_arn
  description = "ARN of the signing job"
}

output "lambda_signing_profile_version_arn" {
  value       = module.lambda_edge_function.lambda_signing_profile_version_arn
  description = "ARN of the signing profile version"
}

output "lambda_source_code_size" {
  value       = module.lambda_edge_function.lambda_source_code_size
  description = "Size in bytes of the function .zip file"
}

output "lambda_tags_all" {
  value       = module.lambda_edge_function.lambda_tags_all
  description = "A map of tags assigned to the resource"
}

output "lambda_version" {
  value       = module.lambda_edge_function.lambda_version
  description = "Latest published version of your Lambda Function"
}