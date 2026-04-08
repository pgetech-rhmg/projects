###############################################################################
# Outputs
###############################################################################

output "bucket_name" {
  description = "S3 bucket name for static asset deployment."
  value       = module.s3_web.bucket_name
}

output "distribution_id" {
  description = "CloudFront distribution ID for cache invalidation."
  value       = module.cloudfront.distribution_id
}
