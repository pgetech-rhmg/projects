# Source Endpoint Outputs
output "source_endpoint_arn" {
  description = "ARN of the DMS source endpoint"
  value       = module.dms_s3_endpoints.source_endpoint_arn
}

output "source_endpoint_id" {
  description = "ID of the DMS source endpoint"
  value       = module.dms_s3_endpoints.source_endpoint_id
}

# S3 Target Endpoint Outputs
output "s3_target_endpoint_arn" {
  description = "ARN of the DMS S3 target endpoint"
  value       = module.dms_s3_endpoints.endpoint_arn
}

output "s3_target_endpoint_id" {
  description = "ID of the DMS S3 target endpoint"
  value       = module.dms_s3_endpoints.endpoint_id
}

output "s3_bucket_name" {
  description = "S3 bucket name where data is stored"
  value       = module.dms_s3_endpoints.s3_bucket_name
}

output "s3_bucket_folder" {
  description = "S3 bucket folder path"
  value       = module.dms_s3_endpoints.s3_bucket_folder
}

output "data_format" {
  description = "Data format used for S3 storage"
  value       = module.dms_s3_endpoints.data_format
}

# IAM Role Outputs
output "dms_s3_service_role_arn" {
  description = "ARN of the IAM role used by DMS to access S3"
  value       = module.dms_s3_access_role.arn
}

output "dms_s3_service_role_name" {
  description = "Name of the IAM role used by DMS to access S3"
  value       = module.dms_s3_access_role.name
}