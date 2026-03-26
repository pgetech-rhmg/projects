variable "batch_size" {
  description = "The largest number of records that Lambda will retrieve from your event source at the time of invocation. Defaults to 100."
  type        = number
  default     = 100
}

variable "bisect_batch_on_function_error" {
  description = "If the function returns an error, split the batch in two and retry."
  type        = bool
  default     = false
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

variable "maximum_record_age_in_seconds" {
  description = " The maximum age of a record that Lambda sends to a function for processing."
  type        = number
  default     = -1
  validation {
    condition     = (var.maximum_record_age_in_seconds == -1 || var.maximum_record_age_in_seconds >= 60 && var.maximum_record_age_in_seconds <= 604800)
    error_message = "Error! The value must be between 60 and 604800."
  }
}

variable "maximum_retry_attempts" {
  description = "The maximum number of times to retry when the function returns an error."
  type        = number
  default     = -1
  validation {
    condition     = (var.maximum_retry_attempts >= -1 && var.maximum_retry_attempts <= 10000)
    error_message = "Error! The value must be between -1 and 10000."
  }
}

variable "parallelization_factor" {
  description = "The number of batches to process from each shard concurrently."
  type        = number
  default     = 1
  validation {
    condition     = (var.parallelization_factor >= 1 && var.parallelization_factor <= 10)
    error_message = "Error! The value must be between 1 and 10."
  }
}

variable "starting_position" {
  description = "The position in the stream where AWS Lambda should start reading. Must be one of LATEST or TRIM_HORIZON."
  type        = string
  validation {
    condition = anytrue([
      var.starting_position == "LATEST",
    var.starting_position == "TRIM_HORIZON"])
    error_message = "Error! The valid value must be  LATEST and TRIM_HORIZON."
  }
}

variable "tumbling_window_in_seconds" {
  description = "The duration in seconds of a processing window for AWS Lambda streaming analytics. The range is between 1 second up to 900 seconds."
  type        = number
  default     = null
  validation {
    condition = (var.tumbling_window_in_seconds == null ? true : (
    var.tumbling_window_in_seconds >= 1 && var.tumbling_window_in_seconds <= 900))
    error_message = "Error! The value must be between 0 and 900."
  }
}

variable "function_response_types" {
  description = " list of current response type enums applied to the event source mapping for AWS Lambda checkpointing.Valid values: ReportBatchItemFailures"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for i in var.function_response_types : contains(["ReportBatchItemFailures"], i)
    ])
    error_message = "Error! Valid values are ReportBatchItemFailures."
  }
}

variable "destination_arn_on_failure" {
  description = "The Amazon Resource Name (ARN) of the destination resource"
  type        = any
  default     = []
}

variable "filter_criteria_pattern" {
  description = "A filter pattern up to 4096 characters"
  type        = any
  default     = []
  validation {
    condition = alltrue([
      length(var.filter_criteria_pattern) <= 4096
    ])
    error_message = "Error! the value must be less than or equal to 4096."
  }
}
