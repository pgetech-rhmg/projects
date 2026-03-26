output "s3_bucket_name" {
  description = "s3 bucket name"
  value       = module.s3.id
}

output "s3_bucket_arn" {
  description = "s3 ARN. Will be of format arn:aws:s3:::bucketname"
  value       = module.s3.arn
}
