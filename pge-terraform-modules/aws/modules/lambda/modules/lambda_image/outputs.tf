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

output "lambda_vpc_config_vpc_id" {
  value       = aws_lambda_function.lambda_function.vpc_config[*].vpc_id
  description = "ID of the VPC"
}

#outputs for aws_lambda_provisioned_concurrency_config
output "provisioned_concurrency_config_id" {
  value       = aws_lambda_provisioned_concurrency_config.provisioned_concurrency_config[*].id
  description = "Lambda Function name and qualifier separated by a colon (:)"
}

#outputs for aws_lambda_event_source_mapping
output "event_source_mapping_function_arn" {
  value       = aws_lambda_event_source_mapping.event_source_mapping[*].function_arn
  description = "The the ARN of the Lambda function the event source mapping is sending events to"
}

output "event_source_mapping_last_modified" {
  value       = aws_lambda_event_source_mapping.event_source_mapping[*].last_modified
  description = "The date this resource was last modified"
}

output "event_source_mapping_last_processing_result" {
  value       = aws_lambda_event_source_mapping.event_source_mapping[*].last_processing_result
  description = "The result of the last AWS Lambda invocation of your Lambda function"
}

output "event_source_mapping_last_state" {
  value       = aws_lambda_event_source_mapping.event_source_mapping[*].state
  description = "The state of the event source mapping"
}

output "event_source_mapping_state_transition_reason" {
  value       = aws_lambda_event_source_mapping.event_source_mapping[*].state_transition_reason
  description = "The reason the event source mapping is in its current state"
}

output "event_source_mapping_uuid" {
  value       = aws_lambda_event_source_mapping.event_source_mapping[*].uuid
  description = "The UUID of the created event source mapping"
}

output "lambda_all" {
  value       = aws_lambda_function.lambda_function
  description = "Map of all Lambda object"
}