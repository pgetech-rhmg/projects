output "s3_bucket_name" {
  description = "s3 bucket name"
  value       = module.s3.id
}

output "s3_bucket_arn" {
  description = "s3 ARN. Will be of format arn:aws:s3:::bucketname"
  value       = module.s3.arn
}

output "is_dc_public_or_internal" {
  description = "DataClassfication passed to the module"
  value       = module.s3.is_dc_public_or_internal
}

output "is_static_web" {
  description = "is bucketType static web or not"
  value       = module.s3.is_static_web
}