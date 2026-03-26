#variables for aws_lambda_alias
variable "lambda_alias_name" {
  description = "Name for the alias you are creating"
  type        = string
  validation {
    condition     = can(regex("([a-zA-Z0-9-_]+)", var.lambda_alias_name))
    error_message = "Error! enter a valid value for aws lambda alias name."
  }
}

variable "lambda_alias_description" {
  description = "Description of the alias"
  type        = string
  default     = null
}

variable "routing_config_additional_version_weights" {
  description = "A map that defines the proportion of events that should be sent to different versions of a lambda function"
  type        = map(string)
  default     = null
}

variable "lambda_alias_function_name" {
  description = "Lambda Function name or ARN"
  type        = string
}

variable "lambda_alias_function_version" {
  description = "Lambda function version for which you are creating the alias"
  type        = string
}