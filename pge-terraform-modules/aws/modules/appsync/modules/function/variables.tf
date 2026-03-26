# Variables for AppSync Function

variable "name" {
  description = "Function name. The function name does not have to be unique."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]*$", var.name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ (underscores)."
  }
}

variable "api_id" {
  description = "ID of the associated AppSync API."
  type        = string
}

variable "data_source" {
  description = "Function data source name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]*$", var.data_source))
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ (underscores)."
  }
}

variable "request_mapping_template" {
  description = "Function request mapping template. Functions support only the 2018-05-29 version of the request mapping template."
  type        = string
}

variable "response_mapping_template" {
  description = "Function response mapping template."
  type        = string
}

variable "description" {
  description = "Function description."
  type        = string
  default     = null
}

variable "max_batch_size" {
  description = "Maximum batching size for a resolver. Valid values are between 0 and 2000."
  type        = number
  default     = 0

  validation {
    condition = (
      var.max_batch_size >= 0 &&
    var.max_batch_size <= 2000)
    error_message = "Error! max_batch_size value should be between 0 and 2000."
  }
}

variable "function_version" {
  description = "Version of the request mapping template. Currently the supported value is 2018-05-29."
  type        = string
  default     = "2018-05-29"
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