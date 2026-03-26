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

# Browser permissions outputs - Permission sets
output "browser_session_permissions" {
  description = "IAM permissions for managing browser sessions"
  value       = local.browser_session_perms
}

output "browser_stream_permissions" {
  description = "IAM permissions for browser streaming operations"
  value       = local.browser_stream_perms
}

output "browser_admin_permissions" {
  description = "IAM permissions for browser administration operations"
  value       = local.browser_admin_perms
}

output "browser_read_permissions" {
  description = "IAM permissions for reading browser information"
  value       = local.browser_read_perms
}

output "browser_list_permissions" {
  description = "IAM permissions for listing browser resources"
  value       = local.browser_list_perms
}

output "browser_use_permissions" {
  description = "IAM permissions for using browser functionality"
  value       = local.browser_use_perms
}

output "browser_full_access_permissions" {
  description = "Full access IAM permissions for all browser operations"
  value       = local.browser_full_access_perms
}

# Browser policy documents
output "browser_full_access_policy" {
  description = "Policy document for granting full access to Bedrock AgentCore Browser operations"
  value       = local.browser_full_access_policy_doc
}

output "browser_session_policy" {
  description = "Policy document for browser session management"
  value       = local.browser_session_policy_doc
}

output "browser_stream_policy" {
  description = "Policy document for browser streaming operations"
  value       = local.browser_stream_policy_doc
}

output "browser_admin_policy" {
  description = "Policy document for browser administration"
  value       = local.browser_admin_policy_doc
}

output "browser_read_policy" {
  description = "Policy document for reading browser information"
  value       = local.browser_read_policy_doc
}

output "browser_list_policy" {
  description = "Policy document for listing browser resources"
  value       = local.browser_list_policy_doc
}

output "browser_use_policy" {
  description = "Policy document for using browser functionality"
  value       = local.browser_use_policy_doc
}