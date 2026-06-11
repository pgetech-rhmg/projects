# Required variables (injected by EPIC)
variable "app_name" {
  description = "Application name used for naming the queue."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, qa, prod)."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}

variable "queue_name" {
  description = "Logical queue name suffix. Combined into pge-epic-<app_name>-<environment>-<queue_name> unless custom_queue_name is provided. The .fifo suffix is appended automatically when fifo_queue is true."
  type        = string
}

# Optional inputs
variable "custom_queue_name" {
  description = "Full queue name override. Takes precedence over the auto-derived name."
  type        = string
  default     = null
  nullable    = true
}

variable "fifo_queue" {
  description = "Create a FIFO queue. The .fifo suffix is automatically added to the queue name."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication. Only valid when fifo_queue is true."
  type        = bool
  default     = false
}

variable "deduplication_scope" {
  description = "FIFO deduplication scope (messageGroup or queue). Only valid when fifo_queue is true."
  type        = string
  default     = null
  nullable    = true
}

variable "fifo_throughput_limit" {
  description = "FIFO throughput limit (perQueue or perMessageGroupId). Only valid when fifo_queue is true."
  type        = string
  default     = null
  nullable    = true
}

variable "delay_seconds" {
  description = "Time in seconds that delivery of all messages in the queue is delayed (0 to 900)."
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "Maximum message size in bytes (1024 to 262144)."
  type        = number
  default     = 262144
}

variable "message_retention_seconds" {
  description = "Number of seconds Amazon SQS retains a message (60 to 1209600). DLQs default to 14 days (1209600) per SAF guidance; override deliberately."
  type        = number
  default     = 1209600
}

variable "receive_wait_time_seconds" {
  description = "Time for which a ReceiveMessage call waits for a message to arrive (0 to 20). Long polling = 20."
  type        = number
  default     = 0
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for the queue in seconds (0 to 43200)."
  type        = number
  default     = 30
}

variable "kms_master_key_id" {
  description = "KMS Key ARN or alias for SSE. Required by SAF for Confidential data; defaults to alias/aws/sqs only when null."
  type        = string
  default     = null
  nullable    = true
}

variable "kms_data_key_reuse_period_seconds" {
  description = "Length of time in seconds for which Amazon SQS can reuse a data key (60 to 86400)."
  type        = number
  default     = 300
}

variable "sqs_managed_sse_enabled" {
  description = "Enable AWS-managed SSE (SSE-SQS) when no kms_master_key_id is provided. SAF prefers a CMK; use sparingly."
  type        = bool
  default     = false
}

variable "redrive_policy" {
  description = "JSON-encoded redrive policy (deadLetterTargetArn + maxReceiveCount)."
  type        = string
  default     = null
  nullable    = true
}

variable "redrive_allow_policy" {
  description = "JSON-encoded redrive allow policy (controls which source queues can use this queue as a DLQ)."
  type        = string
  default     = null
  nullable    = true
}

variable "queue_policy_json" {
  description = "Optional raw JSON queue access policy. When null, a SAF-aligned default is synthesized (TLS-only Allow for allowed_principal_arns + DenyFromInternet on internal_cidr_blocks)."
  type        = string
  default     = null
  nullable    = true
}

variable "allowed_principal_arns" {
  description = "Principal ARNs allowed by the synthesized SAF default queue policy. Required when queue_policy_json is null."
  type        = list(string)
  default     = []
}

variable "internal_cidr_blocks" {
  description = "PG&E internal CIDR blocks used in the synthesized DenyFromInternet condition."
  type        = list(string)
  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
    "131.89.0.0/16",
    "131.90.0.0/16",
  ]
}
