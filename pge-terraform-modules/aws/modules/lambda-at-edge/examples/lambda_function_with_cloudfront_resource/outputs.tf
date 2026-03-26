

################################################

# #aws_cloudfront_distribution
output "cloudfront_distribution_id" {
  description = "The identifier for the distribution."
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "cloudfront_distribution_arn" {
  description = "The ARN (Amazon Resource Name) for the distribution."
  value       = aws_cloudfront_distribution.s3_distribution.arn
}

output "cloudfront_distribution_caller_reference" {
  description = "Internal value used by CloudFront to allow future updates to the distribution configuration."
  value       = aws_cloudfront_distribution.s3_distribution.caller_reference
}

output "cloudfront_distribution_status" {
  description = "The current status of the distribution. Deployed if the distribution's information is fully propagated throughout the Amazon CloudFront system."
  value       = aws_cloudfront_distribution.s3_distribution.status
}

output "cloudfront_distribution_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider."
  value       = aws_cloudfront_distribution.s3_distribution.tags_all
}

output "cloudfront_distribution_trusted_key_groups" {
  description = "List of nested attributes for active trusted key groups, if the distribution is set up to serve private content with signed URLs."
  value       = aws_cloudfront_distribution.s3_distribution.trusted_key_groups
}

output "cloudfront_distribution_trusted_signers" {
  description = "List of nested attributes for active trusted signers, if the distribution is set up to serve private content with signed URLs."
  value       = aws_cloudfront_distribution.s3_distribution.trusted_signers
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to the distribution."
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "cloudfront_distribution_last_modified_time" {
  description = "The date and time the distribution was last modified."
  value       = aws_cloudfront_distribution.s3_distribution.last_modified_time
}

output "cloudfront_distribution_in_progress_validation_batches" {
  description = "The number of invalidation batches currently in progress."
  value       = aws_cloudfront_distribution.s3_distribution.in_progress_validation_batches
}

output "cloudfront_distribution_etag" {
  description = "The current version of the distribution's information."
  value       = aws_cloudfront_distribution.s3_distribution.etag
}

output "s3_bucket_id" {
  description = "s3 bucket name"
  value       = module.s3.id
}

output "s3_bucket_arn" {
  description = "s3 ARN. Will be of format arn:aws:s3:::bucketname"
  value       = module.s3.arn
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
