# – Bedrock Agent Core Gateway Outputs –

output "agent_gateway_id" {
  description = "ID of the created Bedrock AgentCore Gateway"
  value       = try(awscc_bedrockagentcore_gateway.agent_gateway[0].gateway_identifier, null)
}

output "agent_gateway_arn" {
  description = "ARN of the created Bedrock AgentCore Gateway"
  value       = try(awscc_bedrockagentcore_gateway.agent_gateway[0].gateway_arn, null)
}

output "agent_gateway_status" {
  description = "Status of the created Bedrock AgentCore Gateway"
  value       = try(awscc_bedrockagentcore_gateway.agent_gateway[0].status, null)
}

output "agent_gateway_url" {
  description = "URL of the created Bedrock AgentCore Gateway"
  value       = try(awscc_bedrockagentcore_gateway.agent_gateway[0].gateway_url, null)
}

output "agent_gateway_workload_identity_details" {
  description = "Workload identity details of the created Bedrock AgentCore Gateway"
  value       = try(awscc_bedrockagentcore_gateway.agent_gateway[0].workload_identity_details, null)
}

output "agent_gateway_status_reasons" {
  description = "Status reasons of the created Bedrock AgentCore Gateway"
  value       = try(awscc_bedrockagentcore_gateway.agent_gateway[0].status_reasons, null)
}

output "gateway_role_arn" {
  description = "ARN of the IAM role created for the Bedrock AgentCore Gateway"
  value       = try(aws_iam_role.gateway_role[0].arn, null)
}

output "gateway_role_name" {
  description = "Name of the IAM role created for the Bedrock AgentCore Gateway"
  value       = try(aws_iam_role.gateway_role[0].name, null)
}

# – Cognito User Pool Outputs (for JWT Authentication Fallback) –

output "user_pool_id" {
  description = "ID of the Cognito User Pool created as JWT authentication fallback"
  value       = try(aws_cognito_user_pool.default[0].id, null)
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool created as JWT authentication fallback"
  value       = try(aws_cognito_user_pool.default[0].arn, null)
}

output "user_pool_endpoint" {
  description = "Endpoint of the Cognito User Pool created as JWT authentication fallback"
  value       = local.create_user_pool ? "https://${local.user_pool_domain_name}.auth.${data.aws_region.current.region}.amazoncognito.com" : null
}

output "user_pool_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = try(aws_cognito_user_pool_client.default[0].id, null)
}

output "cognito_domain" {
  description = "Domain of the Cognito User Pool"
  value       = try(aws_cognito_user_pool_domain.default[0].domain, null)
}

output "cognito_discovery_url" {
  description = "OpenID Connect discovery URL for the Cognito User Pool"
  value       = local.create_user_pool ? "https://${local.user_pool_domain_name}.auth.${data.aws_region.current.region}.amazoncognito.com/.well-known/openid-configuration" : null
}

output "using_cognito_fallback" {
  description = "Whether the module is using a Cognito User Pool as fallback for JWT authentication"
  value       = local.create_user_pool
}

# – Bedrock Agent Core Code Interpreter Custom Outputs –

output "agent_code_interpreter_id" {
  description = "ID of the created Bedrock AgentCore Code Interpreter Custom"
  value       = try(awscc_bedrockagentcore_code_interpreter_custom.agent_code_interpreter[0].code_interpreter_id, null)
}

output "agent_code_interpreter_arn" {
  description = "ARN of the created Bedrock AgentCore Code Interpreter Custom"
  value       = try(awscc_bedrockagentcore_code_interpreter_custom.agent_code_interpreter[0].code_interpreter_arn, null)
}

output "agent_code_interpreter_status" {
  description = "Status of the created Bedrock AgentCore Code Interpreter Custom"
  value       = try(awscc_bedrockagentcore_code_interpreter_custom.agent_code_interpreter[0].status, null)
}

output "agent_code_interpreter_created_at" {
  description = "Creation timestamp of the created Bedrock AgentCore Code Interpreter Custom"
  value       = try(awscc_bedrockagentcore_code_interpreter_custom.agent_code_interpreter[0].created_at, null)
}

output "agent_code_interpreter_last_updated_at" {
  description = "Last update timestamp of the created Bedrock AgentCore Code Interpreter Custom"
  value       = try(awscc_bedrockagentcore_code_interpreter_custom.agent_code_interpreter[0].last_updated_at, null)
}

output "agent_code_interpreter_failure_reason" {
  description = "Failure reason if the Bedrock AgentCore Code Interpreter Custom failed"
  value       = try(awscc_bedrockagentcore_code_interpreter_custom.agent_code_interpreter[0].failure_reason, null)
}

output "code_interpreter_role_arn" {
  description = "ARN of the IAM role created for the Bedrock AgentCore Code Interpreter Custom"
  value       = try(aws_iam_role.code_interpreter_role[0].arn, null)
}

output "code_interpreter_role_name" {
  description = "Name of the IAM role created for the Bedrock AgentCore Code Interpreter Custom"
  value       = try(aws_iam_role.code_interpreter_role[0].name, null)
}

# – Bedrock Agent Core Browser Custom Outputs –

output "agent_browser_id" {
  description = "ID of the created Bedrock AgentCore Browser Custom"
  value       = try(awscc_bedrockagentcore_browser_custom.agent_browser[0].browser_id, null)
}

output "agent_browser_arn" {
  description = "ARN of the created Bedrock AgentCore Browser Custom"
  value       = try(awscc_bedrockagentcore_browser_custom.agent_browser[0].browser_arn, null)
}

output "agent_browser_status" {
  description = "Status of the created Bedrock AgentCore Browser Custom"
  value       = try(awscc_bedrockagentcore_browser_custom.agent_browser[0].status, null)
}

output "agent_browser_created_at" {
  description = "Creation timestamp of the created Bedrock AgentCore Browser Custom"
  value       = try(awscc_bedrockagentcore_browser_custom.agent_browser[0].created_at, null)
}

output "agent_browser_last_updated_at" {
  description = "Last update timestamp of the created Bedrock AgentCore Browser Custom"
  value       = try(awscc_bedrockagentcore_browser_custom.agent_browser[0].last_updated_at, null)
}

output "agent_browser_failure_reason" {
  description = "Failure reason if the Bedrock AgentCore Browser Custom failed"
  value       = try(awscc_bedrockagentcore_browser_custom.agent_browser[0].failure_reason, null)
}

output "browser_role_arn" {
  description = "ARN of the IAM role created for the Bedrock AgentCore Browser Custom"
  value       = try(aws_iam_role.browser_role[0].arn, null)
}

output "browser_role_name" {
  description = "Name of the IAM role created for the Bedrock AgentCore Browser Custom"
  value       = try(aws_iam_role.browser_role[0].name, null)
}

# – Bedrock Agent Core Workload Identity Outputs –

output "workload_identity_id" {
  description = "ID of the created Bedrock AgentCore Workload Identity"
  value       = try(awscc_bedrockagentcore_workload_identity.workload_identity[0].id, null)
}

output "workload_identity_arn" {
  description = "ARN of the created Bedrock AgentCore Workload Identity"
  value       = try(awscc_bedrockagentcore_workload_identity.workload_identity[0].workload_identity_arn, null)
}

output "workload_identity_created_time" {
  description = "Creation timestamp of the created Bedrock AgentCore Workload Identity"
  value       = try(awscc_bedrockagentcore_workload_identity.workload_identity[0].created_time, null)
}

output "workload_identity_last_updated_time" {
  description = "Last update timestamp of the created Bedrock AgentCore Workload Identity"
  value       = try(awscc_bedrockagentcore_workload_identity.workload_identity[0].last_updated_time, null)
}

# – Bedrock Agent Core Gateway Target Outputs –

output "gateway_target_id" {
  description = "ID of the created Bedrock AgentCore Gateway Target"
  value       = try(aws_bedrockagentcore_gateway_target.gateway_target[0].target_id, null)
}

output "gateway_target_name" {
  description = "Name of the created Bedrock AgentCore Gateway Target"
  value       = try(aws_bedrockagentcore_gateway_target.gateway_target[0].name, null)
}

output "gateway_target_gateway_id" {
  description = "ID of the gateway that this target belongs to"
  value       = try(aws_bedrockagentcore_gateway_target.gateway_target[0].gateway_identifier, null)
}