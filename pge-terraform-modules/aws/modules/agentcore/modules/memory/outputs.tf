# – Bedrock Agent Core Memory Outputs –

output "agent_memory_id" {
  description = "ID of the created Bedrock AgentCore Memory"
  value       = try(awscc_bedrockagentcore_memory.agent_memory[0].memory_id, null)
}

output "agent_memory_arn" {
  description = "ARN of the created Bedrock AgentCore Memory"
  value       = try(awscc_bedrockagentcore_memory.agent_memory[0].memory_arn, null)
}

output "agent_memory_status" {
  description = "Status of the created Bedrock AgentCore Memory"
  value       = try(awscc_bedrockagentcore_memory.agent_memory[0].status, null)
}

output "agent_memory_created_at" {
  description = "Creation timestamp of the created Bedrock AgentCore Memory"
  value       = try(awscc_bedrockagentcore_memory.agent_memory[0].created_at, null)
}

output "agent_memory_updated_at" {
  description = "Last update timestamp of the created Bedrock AgentCore Memory"
  value       = try(awscc_bedrockagentcore_memory.agent_memory[0].updated_at, null)
}

output "memory_role_arn" {
  description = "ARN of the IAM role created for the Bedrock AgentCore Memory"
  value       = try(aws_iam_role.memory_role[0].arn, null)
}

output "memory_role_name" {
  description = "Name of the IAM role created for the Bedrock AgentCore Memory"
  value       = try(aws_iam_role.memory_role[0].name, null)
}

output "memory_kms_policy_arn" {
  description = "ARN of the KMS policy for memory encryption (only available when KMS is provided)"
  value       = local.create_kms_policy ? aws_iam_policy.memory_kms_policy[0].arn : null
}

# Raw permission lists
output "memory_stm_write_permissions" {
  description = "IAM permissions for writing to Short-Term Memory (STM)"
  value       = local.stm_write_perms
}

output "memory_stm_read_permissions" {
  description = "IAM permissions for reading from Short-Term Memory (STM)"
  value       = local.stm_read_perms
}

output "memory_stm_delete_permissions" {
  description = "IAM permissions for deleting from Short-Term Memory (STM)"
  value       = local.stm_delete_perms
}

output "memory_ltm_read_permissions" {
  description = "IAM permissions for reading from Long-Term Memory (LTM)"
  value       = local.ltm_read_perms
}

output "memory_ltm_delete_permissions" {
  description = "IAM permissions for deleting from Long-Term Memory (LTM)"
  value       = local.ltm_delete_perms
}

output "memory_read_permissions" {
  description = "Combined IAM permissions for reading from both Short-Term Memory (STM) and Long-Term Memory (LTM)"
  value       = local.memory_read_perms
}

output "memory_delete_permissions" {
  description = "Combined IAM permissions for deleting from both Short-Term Memory (STM) and Long-Term Memory (LTM)"
  value       = local.memory_delete_perms
}

output "memory_admin_permissions" {
  description = "IAM permissions for memory administration operations"
  value       = local.memory_admin_perms
}

output "memory_full_access_permissions" {
  description = "Full access IAM permissions for all memory operations"
  value       = local.memory_full_access_perms
}

# Ready-to-use policy documents for granting to other resources
output "memory_stm_write_policy" {
  description = "Policy document for granting Short-Term Memory (STM) write permissions"
  value       = local.memory_stm_write_policy_doc
}

output "memory_read_policy" {
  description = "Policy document for granting read permissions to both STM and LTM"
  value       = local.memory_read_policy_doc
}

output "memory_stm_read_policy" {
  description = "Policy document for granting STM read permissions only"
  value       = local.memory_stm_read_policy_doc
}

output "memory_ltm_read_policy" {
  description = "Policy document for granting LTM read permissions only"
  value       = local.memory_ltm_read_policy_doc
}

output "memory_delete_policy" {
  description = "Policy document for granting delete permissions to both STM and LTM"
  value       = local.memory_delete_policy_doc
}

output "memory_stm_delete_policy" {
  description = "Policy document for granting STM delete permissions only"
  value       = local.memory_stm_delete_policy_doc
}

output "memory_ltm_delete_policy" {
  description = "Policy document for granting LTM delete permissions only"
  value       = local.memory_ltm_delete_policy_doc
}

output "memory_admin_policy" {
  description = "Policy document for granting control plane admin permissions"
  value       = local.memory_admin_policy_doc
}

output "memory_full_access_policy" {
  description = "Policy document for granting full access to all memory operations"
  value       = local.memory_full_access_policy_doc
}