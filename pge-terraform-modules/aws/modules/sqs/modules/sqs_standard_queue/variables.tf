####################################### variables of sqs ######################################
variable "sqs_name" {
  type        = string
  description = "The SQS queue name"

  validation {
    condition     = can(regex("([a-zA-Z0-9-_]+)", var.sqs_name))
    error_message = "Error! enter a valid value for aws sqs name."
  }
}

variable "kms_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK"
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  type        = number
  description = "The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again. An integer representing seconds, between 60 seconds (1 minute) and 86,400 seconds (24 hours). The default is 300 (5 minutes)"
  default     = 300

  validation {
    condition = (
      var.kms_data_key_reuse_period_seconds >= 60 &&
    var.kms_data_key_reuse_period_seconds <= 86400)
    error_message = "Error! enter a value between 60 to 86400."
  }
}

variable "visibility_timeout_seconds" {
  type        = number
  description = "The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). The default for this attribute is 30."
  default     = 30

  validation {
    condition = (
      var.visibility_timeout_seconds >= 0 &&
    var.visibility_timeout_seconds <= 43200)
    error_message = "Error! enter a value between 0 to 43200."
  }
}

variable "message_retention_seconds" {
  type        = number
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). The default for this attribute is 345600 (4 days)"
  default     = 345600

  validation {
    condition = (
      var.message_retention_seconds >= 60 &&
    var.message_retention_seconds <= 1209600)
    error_message = "Error! enter a value between 60 to 1209600."
  }
}


variable "max_message_size" {
  type        = number
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB). The default for this attribute is 262144 (256 KiB)"
  default     = 262144

  validation {
    condition = (
      var.max_message_size >= 1024 &&
    var.max_message_size <= 262144)
    error_message = "Error! enter a value between 1024 to 262144."
  }
}

variable "delay_seconds" {
  type        = number
  description = "The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes). The default for this attribute is 0 seconds"
  default     = 0

  validation {
    condition = (
      var.delay_seconds >= 0 &&
    var.delay_seconds <= 900)
    error_message = "Error! enter a value between 0 to 900."
  }
}

variable "receive_wait_time_seconds" {
  type        = number
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds). The default for this attribute is 0, meaning that the call will return immediately"
  default     = 0

  validation {
    condition = (
      var.receive_wait_time_seconds >= 0 &&
    var.receive_wait_time_seconds <= 20)
    error_message = "Error! enter a value between 0 to 20."
  }
}

variable "deduplication_scope" {
  type        = string
  description = "Specifies whether message deduplication occurs at the message group or queue level. Valid values are `messageGroup` and `queue` (default)"
  default     = "queue"

  validation {
    condition = anytrue([
      var.deduplication_scope == "messageGroup",
      var.deduplication_scope == "queue",
    ])
    error_message = "Error! Provide valid values for deduplication scope (messageGroup, queue)."
  }
}

variable "redrive_allow_policy" {
  type        = string
  description = "The JSON policy to set up the Dead Letter Queue redrive permission"
  default     = ""

  validation {
    condition = anytrue([
      var.redrive_allow_policy == "",
      can(jsondecode(var.redrive_allow_policy))
    ])
    error_message = "Error! Invalid JSON for policy. Provide a valid JSON for SQS."
  }
}

variable "redrive_policy" {
  type        = string
  description = " The JSON policy to set up the Dead Letter Queue"
  default     = ""

  validation {
    condition = anytrue([
      var.redrive_policy == "",
      can(jsondecode(var.redrive_policy))
    ])
    error_message = "Error! Invalid JSON for policy. Provide a valid JSON for SQS."
  }
}

variable "policy" {
  description = "Valid JSON document representing a resource policy"
  type        = string
  default     = "{}"

  validation {
    condition     = can(jsondecode(var.policy))
    error_message = "Error! Invalid JSON for policy. Provide a valid JSON for SQS."
  }
}

variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}