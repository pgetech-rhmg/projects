output "deployed_bucket" {
  description = "S3 bucket receiving the deployed website assets"
  value       = var.bucket_name
}

output "file_count" {
  description = "Number of files deployed"
  value       = length(local.all_files)
}

