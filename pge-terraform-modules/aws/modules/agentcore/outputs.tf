# – Bedrock Agent Core Runtime Outputs –

output "agent_runtime_id" {
  description = "ID of the created Bedrock AgentCore Runtime"
  value       = local.agent_runtime_id
}

output "agent_runtime_arn" {
  description = "ARN of the created Bedrock AgentCore Runtime"
  value       = var.runtime_artifact_type == "container" ? try(awscc_bedrockagentcore_runtime.agent_runtime_container[0].agent_runtime_arn, null) : try(awscc_bedrockagentcore_runtime.agent_runtime_code[0].agent_runtime_arn, null)
}

output "agent_runtime_status" {
  description = "Status of the created Bedrock AgentCore Runtime"
  value       = var.runtime_artifact_type == "container" ? try(awscc_bedrockagentcore_runtime.agent_runtime_container[0].status, null) : try(awscc_bedrockagentcore_runtime.agent_runtime_code[0].status, null)
}

output "agent_runtime_version" {
  description = "Version of the created Bedrock AgentCore Runtime"
  value       = var.runtime_artifact_type == "container" ? try(awscc_bedrockagentcore_runtime.agent_runtime_container[0].agent_runtime_version, null) : try(awscc_bedrockagentcore_runtime.agent_runtime_code[0].agent_runtime_version, null)
}

output "agent_runtime_workload_identity_details" {
  description = "Workload identity details of the created Bedrock AgentCore Runtime"
  value       = var.runtime_artifact_type == "container" ? try(awscc_bedrockagentcore_runtime.agent_runtime_container[0].workload_identity_details, null) : try(awscc_bedrockagentcore_runtime.agent_runtime_code[0].workload_identity_details, null)
}

output "runtime_role_arn" {
  description = "ARN of the IAM role created for the Bedrock AgentCore Runtime"
  value       = try(aws_iam_role.runtime_role[0].arn, null)
}

output "runtime_role_name" {
  description = "Name of the IAM role created for the Bedrock AgentCore Runtime"
  value       = try(aws_iam_role.runtime_role[0].name, null)
}

# – Bedrock Agent Core Runtime Endpoint Outputs –

output "agent_runtime_endpoint_id" {
  description = "ID of the created Bedrock AgentCore Runtime Endpoint"
  value       = try(awscc_bedrockagentcore_runtime_endpoint.agent_runtime_endpoint[0].id, null)
}

output "agent_runtime_endpoint_arn" {
  description = "ARN of the created Bedrock AgentCore Runtime Endpoint"
  value       = try(awscc_bedrockagentcore_runtime_endpoint.agent_runtime_endpoint[0].agent_runtime_endpoint_arn, null)
}

output "agent_runtime_endpoint_status" {
  description = "Status of the created Bedrock AgentCore Runtime Endpoint"
  value       = try(awscc_bedrockagentcore_runtime_endpoint.agent_runtime_endpoint[0].status, null)
}

output "agent_runtime_endpoint_live_version" {
  description = "Live version of the created Bedrock AgentCore Runtime Endpoint"
  value       = try(awscc_bedrockagentcore_runtime_endpoint.agent_runtime_endpoint[0].live_version, null)
}

output "agent_runtime_endpoint_target_version" {
  description = "Target version of the created Bedrock AgentCore Runtime Endpoint"
  value       = try(awscc_bedrockagentcore_runtime_endpoint.agent_runtime_endpoint[0].target_version, null)
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