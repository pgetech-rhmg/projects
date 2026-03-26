variable "api_id" {
  description = "API ID for the GraphQL API."
  type        = string
}

variable "type" {
  description = "Type name from the schema defined in the GraphQL API."
  type        = string
}

variable "field" {
  description = "Field name from the schema defined in the GraphQL API."
  type        = string
}

variable "request_template" {
  description = "Request mapping template for UNIT resolver or 'before mapping template' for PIPELINE resolver. Required for non-Lambda resolvers."
  type        = string
  default     = null
}

variable "response_template" {
  description = "Response mapping template for UNIT resolver or 'after mapping template' for PIPELINE resolver. Required for non-Lambda resolvers."
  type        = string
  default     = null
}

variable "data_source" {
  description = "Data source name."
  type        = string
  default     = null

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]*$", var.data_source)) || var.data_source == null
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ (underscores)."
  }
}

variable "max_batch_size" {
  description = " Maximum batching size for a resolver. Valid values are between 0 and 2000."
  type        = string
  default     = 0

  validation {
    condition = (
    var.max_batch_size >= 0 && var.max_batch_size <= 2000)
    error_message = "Error! max_batch_size should be between 0 and 2000."
  }
}

variable "kind" {
  description = "Resolver type. Valid values are UNIT and PIPELINE."
  type        = string
  default     = null

  validation {
    condition = anytrue([var.kind == null,
      var.kind == "UNIT",
    var.kind == "PIPELINE"])
    error_message = "Error! enter valid values for Kind. valid values are UNIT and PIPELINE."
  }
}

variable "sync_config" {
  description = <<-DOC
  conflict_detection :
    Conflict Detection strategy to use. Valid values are NONE and VERSION.
  conflict_handler :
    Conflict Resolution strategy to perform in the event of a conflict. Valid values are NONE, OPTIMISTIC_CONCURRENCY, AUTOMERGE, and LAMBDA.
  lambda_conflict_handler_arn :
    ARN for the Lambda function to use as the Conflict Handler.
  DOC

  type = object({
    conflict_detection          = optional(string)
    conflict_handler            = optional(string)
    lambda_conflict_handler_arn = optional(string)
  })

  default = {
    conflict_detection          = null
    conflict_handler            = null
    lambda_conflict_handler_arn = null
  }

  validation {
    condition     = var.sync_config.conflict_detection != null ? contains(["NONE", "VERSION"], var.sync_config.conflict_detection) : true
    error_message = "Error! enter valid values for conflict_detection. valid values are NONE and VERSION."
  }

  validation {
    condition     = var.sync_config.conflict_handler != null ? contains(["NONE", "OPTIMISTIC_CONCURRENCY", "AUTOMERGE", "LAMBDA"], var.sync_config.conflict_handler) : true
    error_message = "Error! enter valid values for conflict_handler. valid values are NONE, OPTIMISTIC_CONCURRENCY, AUTOMERGE, and LAMBDA."
  }

  validation {
    condition     = var.sync_config.lambda_conflict_handler_arn != null ? can(regex("^arn:aws:lambda:\\w+(?:-\\w+)+:[[:digit:]]{12}:function:([a-zA-Z0-9])+(.*)$", var.sync_config.lambda_conflict_handler_arn)) : true
    error_message = "The lambda_conflict_handler_arn is required and the allowed format is arn:aws:lambda:<region>:<account-id>:function:<function_name>."
  }

  validation {
    condition     = var.sync_config.conflict_handler == "LAMBDA" ? var.sync_config.lambda_conflict_handler_arn != null : true
    error_message = "Error! If the conflict_handler is 'LAMBDA' then the lambda_conflict_handler_arn is required!"
  }
}

variable "caching_keys" {
  description = "List of caching key."
  type        = list(string)
  default     = []
}

variable "ttl" {
  description = "TTL in seconds."
  type        = number
  default     = null
}

variable "pipeline_config" {
  description = "PipelineConfig"
  type        = map(any)
  default     = null
}