output "mimir_ruler_bucket_name" {
  description = "S3 bucket name for Mimir ruler storage."
  value       = module.mimir_ruler_bucket.id
}

output "mimir_ruler_bucket_arn" {
  description = "S3 ARN for Mimir ruler storage."
  value       = module.mimir_ruler_bucket.arn
}

output "mimir_blocks_bucket_name" {
  description = "S3 bucket name for Mimir blocks storage."
  value       = module.mimir_blocks_bucket.id
}

output "mimir_blocks_bucket_arn" {
  description = "S3 ARN for Mimir blocks storage."
  value       = module.mimir_blocks_bucket.arn
}