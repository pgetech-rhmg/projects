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

# Code Interpreter permissions outputs - Permission sets
output "code_interpreter_session_permissions" {
  description = "IAM permissions for managing code interpreter sessions"
  value       = local.code_interpreter_session_perms
}

output "code_interpreter_invoke_permissions" {
  description = "IAM permissions for invoking code interpreter"
  value       = local.code_interpreter_invoke_perms
}

output "code_interpreter_admin_permissions" {
  description = "IAM permissions for code interpreter administration operations"
  value       = local.code_interpreter_admin_perms
}

output "code_interpreter_read_permissions" {
  description = "IAM permissions for reading code interpreter information"
  value       = local.code_interpreter_read_perms
}

output "code_interpreter_list_permissions" {
  description = "IAM permissions for listing code interpreter resources"
  value       = local.code_interpreter_list_perms
}

output "code_interpreter_use_permissions" {
  description = "IAM permissions for using code interpreter functionality"
  value       = local.code_interpreter_use_perms
}

output "code_interpreter_full_access_permissions" {
  description = "Full access IAM permissions for all code interpreter operations"
  value       = local.code_interpreter_full_access_perms
}

# Code Interpreter policy documents
output "code_interpreter_full_access_policy" {
  description = "Policy document for granting full access to Bedrock AgentCore Code Interpreter operations"
  value       = local.code_interpreter_full_access_policy_doc
}

output "code_interpreter_session_policy" {
  description = "Policy document for code interpreter session management"
  value       = local.code_interpreter_session_policy_doc
}

output "code_interpreter_invoke_policy" {
  description = "Policy document for code interpreter invocation operations"
  value       = local.code_interpreter_invoke_policy_doc
}

output "code_interpreter_admin_policy" {
  description = "Policy document for code interpreter administration"
  value       = local.code_interpreter_admin_policy_doc
}

output "code_interpreter_read_policy" {
  description = "Policy document for reading code interpreter information"
  value       = local.code_interpreter_read_policy_doc
}

output "code_interpreter_list_policy" {
  description = "Policy document for listing code interpreter resources"
  value       = local.code_interpreter_list_policy_doc
}

output "code_interpreter_use_policy" {
  description = "Policy document for using code interpreter functionality"
  value       = local.code_interpreter_use_policy_doc
}
