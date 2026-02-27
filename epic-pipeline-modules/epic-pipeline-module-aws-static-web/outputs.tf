output "bucket_name" {
  description = "S3 bucket name."
  value       = module.s3.bucket_name
}

output "bucket_arn" {
  description = "S3 bucket ARN."
  value       = module.s3.bucket_arn
}

output "bucket_domain_name" {
  description = "S3 bucket domain name."
  value       = module.s3.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "S3 bucket regional domain name."
  value       = module.s3.bucket_regional_domain_name
}

output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = module.cloudfront.distribution_arn
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.distribution_domain_name
}
