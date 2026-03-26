#outputs for aws_lambda_function
output "lambda_arn" {
  value       = aws_lambda_function.lambda_function.arn
  description = "Amazon Resource Name (ARN) identifying your Lambda Function"
}

output "lambda_invoke_arn" {
  value       = aws_lambda_function.lambda_function.invoke_arn
  description = "ARN to be used for invoking Lambda Function from API Gateway - to be used in aws_api_gateway_integration's uri"
}

output "lambda_last_modified" {
  value       = aws_lambda_function.lambda_function.last_modified
  description = "Date this resource was last modified"
}

output "lambda_qualified_arn" {
  value       = aws_lambda_function.lambda_function.qualified_arn
  description = "ARN identifying your Lambda Function Version (if versioning is enabled via publish = true)"
}

output "lambda_signing_job_arn" {
  value       = aws_lambda_function.lambda_function.signing_job_arn
  description = "ARN of the signing job"
}

output "lambda_signing_profile_version_arn" {
  value       = aws_lambda_function.lambda_function.signing_profile_version_arn
  description = "ARN of the signing profile version"
}

output "lambda_source_code_size" {
  value       = aws_lambda_function.lambda_function.source_code_size
  description = "Size in bytes of the function .zip file"
}

output "lambda_tags_all" {
  value       = aws_lambda_function.lambda_function.tags_all
  description = "A map of tags assigned to the resource"
}

output "lambda_version" {
  value       = aws_lambda_function.lambda_function.version
  description = "Latest published version of your Lambda Function"
}

output "lambda_all" {
  value       = aws_lambda_function.lambda_function
  description = "Map of all attributes"
}

output "lambda_region" {
  value       = data.external.validate_region
  description = "The region of the Lambda Function"
}

output "lambda_permission_all" {
  value       = aws_lambda_permission.lambda_permission
  description = "Map of all attributes"
}

output "lambda_function_event_invoke_config" {
  value       = aws_lambda_function_event_invoke_config.event_invoke_config
  description = "Map of all attributes"
}
