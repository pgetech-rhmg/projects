variable "endpoint" {
  description = "Endpoint to send data to. The contents vary with the protocol"
  type        = list(string)
}

variable "protocol" {
  description = "Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application.Protocols email, email-json, http and https are also valid but partially supported."
  type        = string
  default     = "email"
  validation {
    condition     = contains(["sqs", "sms", "lambda", "firehose", "application", "email", "email-json", "http", "https"], var.protocol)
    error_message = "Valid values for protocol are (sqs,sms,lambda,firehose,applicationt,email,email-json,http,https)."
  }
}

variable "subscription_role_arn" {
  description = "ARN of the IAM role to publish to Kinesis Data Firehose delivery stream"
  type        = string
  default     = null
}

variable "confirmation_timeout_in_minutes" {
  description = "Integer indicating number of minutes to wait in retrying mode for fetching subscription arn before marking it as failure. Only applicable for http and https protocols"
  type        = number
  default     = null
}

variable "delivery_policy" {
  description = "JSON String with the delivery policy (retries, backoff, etc.) that will be used in the subscription - this only applies to HTTP/S subscriptions"
  type        = string
  default     = null
}

variable "endpoint_auto_confirms" {
  description = "Whether the endpoint is capable of auto confirming subscription "
  type        = bool
  default     = false
}

variable "filter_policy" {
  description = " JSON String with the filter policy that will be used in the subscription to filter messages seen by the target resource"
  type        = string
  default     = null
}

variable "raw_message_delivery" {
  description = "Whether to enable raw message delivery (the original message is directly passed, not wrapped in JSON with the original message in the message property)"
  type        = bool
  default     = false
}

variable "redrive_policy" {
  description = "JSON String with the redrive policy that will be used in the subscription"
  type        = string
  default     = null
}

variable "topic_arn" {
  description = "ARN of the SNS topic to subscribe to."
  type        = string
}