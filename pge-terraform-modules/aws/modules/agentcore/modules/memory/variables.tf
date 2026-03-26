# – Agent Core Memory –

variable "create_memory" {
  description = "Whether or not to create an agent core memory."
  type        = bool
  default     = false
}

variable "memory_name" {
  description = "The name of the agent core memory."
  type        = string
  default     = "TerraformBedrockAgentCoreMemory"
}

variable "memory_description" {
  description = "Description of the agent core memory."
  type        = string
  default     = null
}

variable "memory_event_expiry_duration" {
  description = "Duration in days until memory events expire."
  type        = number
  default     = 90
}

variable "memory_execution_role_arn" {
  description = "Optional IAM role ARN for the Bedrock agent core memory."
  type        = string
  default     = null
}

variable "memory_encryption_key_arn" {
  description = "The ARN of the KMS key used to encrypt the memory."
  type        = string
  default     = null
}

variable "memory_strategies" {
  description = "List of memory strategies attached to this memory."
  type = list(object({
    semantic_memory_strategy = optional(object({
      name        = optional(string)
      description = optional(string)
      namespaces  = optional(list(string))
    }))
    summary_memory_strategy = optional(object({
      name        = optional(string)
      description = optional(string)
      namespaces  = optional(list(string))
    }))
    user_preference_memory_strategy = optional(object({
      name        = optional(string)
      description = optional(string)
      namespaces  = optional(list(string))
    }))
    custom_memory_strategy = optional(object({
      name        = optional(string)
      description = optional(string)
      namespaces  = optional(list(string))
      configuration = optional(object({
        self_managed_configuration = optional(object({
          historical_context_window_size = optional(number, 4) # Default to 4 messages
          invocation_configuration = object({
            # Both fields are required when a self-managed configuration is used
            payload_delivery_bucket_name = string
            topic_arn                    = string
          })
          trigger_conditions = optional(list(object({
            message_based_trigger = optional(object({
              message_count = optional(number, 1) # Default to 1 message
            }))
            time_based_trigger = optional(object({
              idle_session_timeout = optional(number, 10) # Default to 10 seconds
            }))
            token_based_trigger = optional(object({
              token_count = optional(number, 100) # Default to 100 tokens
            }))
          })))
        }))
        semantic_override = optional(object({
          consolidation = optional(object({
            append_to_prompt = optional(string)
            model_id         = optional(string)
          }))
          extraction = optional(object({
            append_to_prompt = optional(string)
            model_id         = optional(string)
          }))
        }))
        summary_override = optional(object({
          consolidation = optional(object({
            append_to_prompt = optional(string)
            model_id         = optional(string)
          }))
        }))
        user_preference_override = optional(object({
          consolidation = optional(object({
            append_to_prompt = optional(string)
            model_id         = optional(string)
          }))
          extraction = optional(object({
            append_to_prompt = optional(string)
            model_id         = optional(string)
          }))
        }))
      }))
    }))
  }))
  default = []
}

variable "memory_tags" {
  description = "A map of tag keys and values for the agent core memory."
  type        = map(string)
  default     = null
}

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
}

variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
}

variable "Order" {
  type        = number
  description = "Order as a tag to be associated with an AWS resource"
}

# - IAM -
variable "permissions_boundary_arn" {
  description = "The ARN of the IAM permission boundary for the role."
  type        = string
  default     = null
}