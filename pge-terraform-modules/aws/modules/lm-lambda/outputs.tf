##################################################################
#
#  Filename    : aws/modules/lm-lambda/outputs.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Terraform module creates a Lambda Function for Locaste & Mark
#
##################################################################
output "arn" {
  value       = aws_lambda_function.lambda_function.arn
  description = "Amazon Resource Name (ARN) identifying your Lambda Function"
}

output "invoke_arn" {
  value       = aws_lambda_function.lambda_function.invoke_arn
  description = "ARN to be used for invoking Lambda Function from API Gateway - to be used in aws_api_gateway_integration's uri"
}

output "alias_arn" {
  value       = aws_lambda_alias.lambda_alias.arn
  description = "ARN of the Lambda Function Latest Alias"
}

output "last_modified" {
  value       = aws_lambda_function.lambda_function.last_modified
  description = "Date this resource was last modified"
}

output "qualified_arn" {
  value       = aws_lambda_function.lambda_function.qualified_arn
  description = "ARN identifying your Lambda Function Version (if versioning is enabled via publish = true)"
}

output "signing_job_arn" {
  value       = aws_lambda_function.lambda_function.signing_job_arn
  description = "ARN of the signing job"
}

output "signing_profile_version_arn" {
  value       = aws_lambda_function.lambda_function.signing_profile_version_arn
  description = "ARN of the signing profile version"
}

output "source_code_size" {
  value       = aws_lambda_function.lambda_function.source_code_size
  description = "Size in bytes of the function .zip file"
}

output "tags_all" {
  value       = aws_lambda_function.lambda_function.tags_all
  description = "A map of tags assigned to the resource"
}

output "version" {
  value       = aws_lambda_function.lambda_function.version
  description = "Latest published version of your Lambda Function"
}

output "vpc_config_vpc_id" {
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

output "ecr_arn" {
  description = "Full ARN of the ECR repository."
  value       = module.ecr.ecr_arn
}

output "ecr_url" {
  description = "URL of the ECR repository."
  value       = module.ecr.ecr_repository_url
}

output "ecr_id" {
  description = "Id of the ECR registry."
  value       = module.ecr.ecr_registry_id
}

output "ecr_all" {
  description = "All attributes of ECR repository"
  value       = module.ecr.ecr_all
}

output "lambda_execution_role_arn" {
  description = "IAM role ARN for Lambda execution"
  value       = local.lambda_role
}
