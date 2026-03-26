output "lambda_arn" {
  value       = module.lambda_edge_function.lambda_arn
  description = "Amazon Resource Name (ARN) identifying your Lambda Function"
}

output "lambda_invoke_arn" {
  value       = module.lambda_edge_function.lambda_invoke_arn
  description = "ARN to be used for invoking Lambda Function from API Gateway - to be used in aws_api_gateway_integration's uri"
}

output "lambda_last_modified" {
  value       = module.lambda_edge_function.lambda_last_modified
  description = "Date this resource was last modified"
}

output "lambda_qualified_arn" {
  value       = module.lambda_edge_function.lambda_qualified_arn
  description = "ARN identifying your Lambda Function Version (if versioning is enabled via publish = true)"
}

output "lambda_signing_job_arn" {
  value       = module.lambda_edge_function.lambda_signing_job_arn
  description = "ARN of the signing job"
}

output "lambda_signing_profile_version_arn" {
  value       = module.lambda_edge_function.lambda_signing_profile_version_arn
  description = "ARN of the signing profile version"
}

output "lambda_source_code_size" {
  value       = module.lambda_edge_function.lambda_source_code_size
  description = "Size in bytes of the function .zip file"
}

output "lambda_tags_all" {
  value       = module.lambda_edge_function.lambda_tags_all
  description = "A map of tags assigned to the resource"
}

output "lambda_version" {
  value       = module.lambda_edge_function.lambda_version
  description = "Latest published version of your Lambda Function"
}
