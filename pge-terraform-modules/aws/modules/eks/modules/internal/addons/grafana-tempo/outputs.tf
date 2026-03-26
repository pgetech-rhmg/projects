output "traces_bucket_name" {
  description = "S3 bucket name for Tempo traces storage."
  value       = module.tempo_traces_bucket.id
}

output "traces_bucket_arn" {
  description = "S3 ARN for Tempo traces storage."
  value       = module.tempo_traces_bucket.arn
}