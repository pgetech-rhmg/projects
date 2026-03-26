output "agent_runtime_id" {
  description = "ID of the created Bedrock Agent Runtime"
  value       = module.bedrock_agent_runtime.agent_runtime_id
}

output "agent_runtime_arn" {
  description = "ARN of the created Bedrock Agent Runtime"
  value       = module.bedrock_agent_runtime.agent_runtime_arn
}

output "agent_runtime_endpoint_id" {
  description = "ID of the created Bedrock Agent Runtime Endpoint"
  value       = module.bedrock_agent_runtime.agent_runtime_endpoint_id
}

output "agent_runtime_endpoint_arn" {
  description = "ARN of the created Bedrock Agent Runtime Endpoint"
  value       = module.bedrock_agent_runtime.agent_runtime_endpoint_arn
}

output "agent_runtime_endpoint_status" {
  description = "Status of the created Bedrock Agent Runtime Endpoint"
  value       = module.bedrock_agent_runtime.agent_runtime_endpoint_status
}

# output "aws_ecr_repository_url" {
#   description = "URL of the ECR repository for the agent runtime container"
#   value       = aws_ecr_repository.agent_runtime.repository_url
# }

# Outputs for memory and strategies will be conditionally included based on whether memory is created, defined in the outputs.tf file within the agentcore_memory module.
output "memory_id" {
  description = "ID of the AgentCore memory"
  value       = var.create_memory ? aws_bedrockagentcore_memory.agent_memory[0].id : null
}

output "memory_arn" {
  description = "ARN of the AgentCore memory"
  value       = var.create_memory ? aws_bedrockagentcore_memory.agent_memory[0].arn : null
}

output "semantic_strategy_id" {
  description = "ID of the semantic memory strategy"
  value       = var.create_memory ? aws_bedrockagentcore_memory_strategy.semantic[0].memory_strategy_id : null
}

output "summary_strategy_id" {
  description = "ID of the summarization memory strategy"
  value       = var.create_memory ? aws_bedrockagentcore_memory_strategy.summarization[0].memory_strategy_id : null
}

output "user_preference_strategy_id" {
  description = "ID of the user preference memory strategy"
  value       = var.create_memory ? aws_bedrockagentcore_memory_strategy.user_preference[0].memory_strategy_id : null
}