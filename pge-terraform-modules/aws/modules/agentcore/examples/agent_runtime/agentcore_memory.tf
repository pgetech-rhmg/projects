# ========================================
# Bedrock AgentCore Memory and Strategy
# ========================================
# Configure memory and strategy for the AgentCore runtime to enable 
# advanced memory capabilities for agents

# # Variable for creating memory
# variable "create_memory" {
#   description = "Whether to create AgentCore memory and strategy"
#   type        = bool
#   default     = false
# }

# First, create the AgentCore Memory resource
# This provides the underlying memory infrastructure
resource "aws_bedrockagentcore_memory" "agent_memory" {
  count = var.create_memory ? 1 : 0

  name                  = "${replace(var.runtime_name, "-", "_")}_memory"
  description           = "Memory for ${var.runtime_name} agents with persistent context"
  event_expiry_duration = 30 # Events expire after 30 days (range: 7-365)

  # Optional: Use custom IAM role for memory operations with model processing
  # memory_execution_role_arn = aws_iam_role.memory_execution_role[0].arn
}

# Memory Strategy: SEMANTIC
# Enables semantic understanding and retrieval of conversation context
resource "aws_bedrockagentcore_memory_strategy" "semantic" {
  count = var.create_memory ? 1 : 0

  name        = "${replace(var.runtime_name, "-", "_")}_semantic"
  memory_id   = aws_bedrockagentcore_memory.agent_memory[0].id
  type        = "SEMANTIC"
  description = "Semantic understanding strategy for context retrieval"
  namespaces  = ["{sessionId}"]
}

# Memory Strategy: SUMMARIZATION
# Automatically summarizes conversation history
resource "aws_bedrockagentcore_memory_strategy" "summarization" {
  count = var.create_memory ? 1 : 0

  name        = "${replace(var.runtime_name, "-", "_")}_summary"
  memory_id   = aws_bedrockagentcore_memory.agent_memory[0].id
  type        = "SUMMARIZATION"
  description = "Conversation summarization strategy"
  namespaces  = ["{sessionId}"]
}

# Memory Strategy: USER_PREFERENCE
# Tracks and remembers user preferences across sessions
resource "aws_bedrockagentcore_memory_strategy" "user_preference" {
  count = var.create_memory ? 1 : 0

  name        = "${replace(var.runtime_name, "-", "_")}_user_pref"
  memory_id   = aws_bedrockagentcore_memory.agent_memory[0].id
  type        = "USER_PREFERENCE"
  description = "User preference tracking strategy"
  namespaces  = ["{actorId}"]
}
