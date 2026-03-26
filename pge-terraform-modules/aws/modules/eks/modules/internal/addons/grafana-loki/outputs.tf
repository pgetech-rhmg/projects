output "loki_chunks_bucket_name" {
  description = "Loki chunks s3 bucket name"
  value       = module.loki_chunks_bucket.id
}

output "loki_chunks_bucket_arn" {
  description = "Loki chunks s3 ARN"
  value       = module.loki_chunks_bucket.arn
}

output "loki_ruler_bucket_name" {
  description = "Loki ruler s3 bucket name"
  value       = module.loki_ruler_bucket.id
}

output "loki_ruler_bucket_arn" {
  description = "Loki ruler s3 ARN"
  value       = module.loki_ruler_bucket.arn
}