variable "batch_size" {
  description = "The largest number of records that Lambda will retrieve from your event source at the time of invocation."
  type        = number
  default     = 10
}

variable "enabled" {
  description = "Determines if the mapping will be enabled on creation"
  type        = bool
  default     = true
}

variable "event_source_arn" {
  description = "The event source ARN"
  type        = string
}

variable "function_name" {
  description = "The name or the ARN of the Lambda function that will be subscribing to events"
  type        = string
  validation {
    condition = anytrue([
      can(regex("^[a-zA-Z0-9]", var.function_name)) ||
      can(regex("^arn:aws:lambda:\\w+(?:-\\w+)+:[[:digit:]]{12}:key/([a-zA-Z0-9])+(.*)$", var.function_name))
    ])
    error_message = "Error! enter a valid name or arn."
  }
}

variable "maximum_batching_window_in_seconds" {
  description = "The maximum amount of time to gather records before invoking the function, in seconds (between 0 and 300)"
  type        = number
  default     = null
  validation {
    condition = (var.maximum_batching_window_in_seconds == null ? true : (
    var.maximum_batching_window_in_seconds >= 0 && var.maximum_batching_window_in_seconds <= 300))
    error_message = "Error! The value must be between 0 and 300."
  }
}

variable "filter_criteria_pattern" {
  description = "A filter pattern up to 4096 characters"
  type        = any
  default     = []
  validation {
    condition = alltrue([
      length(var.filter_criteria_pattern) <= 4096
    ])
    error_message = "Error! the length should be less than or equal to 4096."
  }
}

variable "function_response_types" {
  description = " list of current response type enums applied to the event source mapping for AWS Lambda checkpointing."
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for i in var.function_response_types : contains(["ReportBatchItemFailures"], i)
    ])
    error_message = "Error! Valid values are ReportBatchItemFailures."
  }
}