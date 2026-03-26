#outputs for aws_lambda_layer_version
output "layer_version_arn" {
  value       = module.lambda_layer_version.layer_version_arn
  description = "ARN of the Lambda Layer with version"
}

output "layer_version_created_date" {
  value       = module.lambda_layer_version.layer_version_created_date
  description = "Date this resource was created"
}

output "layer_version_layer_arn" {
  value       = module.lambda_layer_version.layer_version_layer_arn
  description = "ARN of the Lambda Layer without version"
}

output "layer_version_signing_job_arn" {
  value       = module.lambda_layer_version.layer_version_signing_job_arn
  description = "ARN of a signing job"
}

output "layer_version_signing_profile_version_arn" {
  value       = module.lambda_layer_version.layer_version_signing_profile_version_arn
  description = "ARN for a signing profile version"
}

output "layer_version_source_code_size" {
  value       = module.lambda_layer_version.layer_version_source_code_size
  description = "Size in bytes of the function .zip file"
}

output "layer_version_version" {
  value       = module.lambda_layer_version.layer_version_version
  description = "Lambda Layer version"
}

#outputs for aws_lambda_layer_version_permission
output "layer_version_permission_id" {
  value       = module.lambda_layer_version[*].layer_version_permission_id
  description = "The layer_name and version_number, separated by a comma (,)"
}

output "layer_version_permission_revision_id" {
  value       = module.lambda_layer_version[*].layer_version_permission_revision_id
  description = "A unique identifier for the current revision of the policy"
}

output "layer_version_permission_policy" {
  value       = module.lambda_layer_version[*].layer_version_permission_policy
  description = "Full Lambda Layer Permission policy"
}