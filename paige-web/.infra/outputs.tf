###############################################################################
# Outputs
###############################################################################

output "bucket_name" {
  value = module.s3_web.bucket_name
}

output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}
