# Source endpoint outputs
output "source_endpoint_arn" {
  description = "ARN of the DMS source endpoint"
  value       = aws_dms_endpoint.dms_source_endpoint.endpoint_arn
}

output "source_endpoint_id" {
  description = "ID of the DMS source endpoint"
  value       = aws_dms_endpoint.dms_source_endpoint.endpoint_id
}

output "source_endpoint_type" {
  description = "Type of the DMS source endpoint"
  value       = aws_dms_endpoint.dms_source_endpoint.endpoint_type
}

output "source_engine_name" {
  description = "Engine name of the DMS source endpoint"
  value       = aws_dms_endpoint.dms_source_endpoint.engine_name
}

# S3 target endpoint outputs
output "endpoint_arn" {
  description = "ARN of the DMS S3 target endpoint"
  value       = aws_dms_s3_endpoint.dms_s3_target_endpoint.endpoint_arn
}

output "endpoint_id" {
  description = "ID of the DMS S3 target endpoint"
  value       = aws_dms_s3_endpoint.dms_s3_target_endpoint.endpoint_id
}

output "endpoint_type" {
  description = "Type of the DMS endpoint"
  value       = aws_dms_s3_endpoint.dms_s3_target_endpoint.endpoint_type
}

output "engine_display_name" {
  description = "Engine display name of the DMS endpoint"
  value       = aws_dms_s3_endpoint.dms_s3_target_endpoint.engine_display_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket used by the DMS endpoint"
  value       = var.s3_bucket_name
}

output "s3_bucket_folder" {
  description = "Folder path within the S3 bucket"
  value       = var.s3_bucket_folder
}

output "data_format" {
  description = "Data format used by the DMS S3 endpoint"
  value       = var.data_format
}

output "compression_type" {
  description = "Compression type used by the DMS S3 endpoint"
  value       = var.compression_type
}