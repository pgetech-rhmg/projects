# #aws_cloudfront_distribution
output "cloudfront_distribution_id" {
  description = "The identifier for the distribution."
  value       = aws_cloudfront_distribution.cf_distribution.id
}

output "cloudfront_distribution_arn" {
  description = "The ARN (Amazon Resource Name) for the distribution."
  value       = aws_cloudfront_distribution.cf_distribution.arn
}

output "cloudfront_distribution_all" {
  description = "Map of all cloudfront_distribution attributes"
  value       = aws_cloudfront_distribution.cf_distribution
}

output "cloudfront_distribution_caller_reference" {
  description = "Internal value used by CloudFront to allow future updates to the distribution configuration."
  value       = aws_cloudfront_distribution.cf_distribution.caller_reference
}

output "cloudfront_distribution_status" {
  description = "The current status of the distribution. Deployed if the distribution's information is fully propagated throughout the Amazon CloudFront system."
  value       = aws_cloudfront_distribution.cf_distribution.status
}

output "cloudfront_distribution_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider."
  value       = aws_cloudfront_distribution.cf_distribution.tags_all
}

output "cloudfront_distribution_trusted_key_groups" {
  description = "List of nested attributes for active trusted key groups, if the distribution is set up to serve private content with signed URLs."
  value       = aws_cloudfront_distribution.cf_distribution.trusted_key_groups
}

output "cloudfront_distribution_trusted_signers" {
  description = "List of nested attributes for active trusted signers, if the distribution is set up to serve private content with signed URLs."
  value       = aws_cloudfront_distribution.cf_distribution.trusted_signers
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to the distribution."
  value       = aws_cloudfront_distribution.cf_distribution.domain_name
}

output "cloudfront_distribution_last_modified_time" {
  description = "The date and time the distribution was last modified."
  value       = aws_cloudfront_distribution.cf_distribution.last_modified_time
}

output "cloudfront_distribution_in_progress_validation_batches" {
  description = "The number of invalidation batches currently in progress."
  value       = aws_cloudfront_distribution.cf_distribution.in_progress_validation_batches
}

output "cloudfront_distribution_etag" {
  description = "The current version of the distribution's information."
  value       = aws_cloudfront_distribution.cf_distribution.etag
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID that can be used to route an Alias Resource Record Set to. This attribute is simply an alias for the zone ID."
  value       = aws_cloudfront_distribution.cf_distribution.hosted_zone_id
}

# #aws_cloudfront_monitoring_subscription
output "monitoring_subscription_id" {
  description = "The ID of the CloudFront monitoring subscription, which corresponds to the distribution_id."
  value = {
    for index, value in aws_cloudfront_monitoring_subscription.cf_monitoring_subscription : index => value.id
  }
}

# #aws_cloudfront_realtime_log_config
output "realtime_log_config_id" {
  description = "The ID of the CloudFront real-time log configuration."
  value = {
    for index, value in aws_cloudfront_realtime_log_config.cf_realtime_log_config : index => value.id
  }
}

output "realtime_log_config_arn" {
  description = "The ARN (Amazon Resource Name) of the CloudFront real-time log configuration."
  value = {
    for index, value in aws_cloudfront_realtime_log_config.cf_realtime_log_config : index => value.arn
  }
}
