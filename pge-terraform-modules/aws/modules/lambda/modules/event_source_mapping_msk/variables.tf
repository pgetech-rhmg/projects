variable "batch_size" {
  description = "The largest number of records that Lambda will retrieve from your event source at the time of invocation. Defaults to 100."
  type        = number
  default     = 100
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

variable "starting_position" {
  description = "The position in the stream where AWS Lambda should start reading. Must be one of AT_TIMESTAMP, LATEST or TRIM_HORIZON."
  type        = string
  validation {
    condition = anytrue([
      var.starting_position == "LATEST",
    var.starting_position == "TRIM_HORIZON"])
    error_message = "Error! The valid value must be LATEST and TRIM_HORIZON."
  }
}

variable "topics" {
  description = "The name of the Kafka topics."
  type        = list(string)
}

variable "source_access_configuration" {
  description = <<-DOC
    type:
       The type of this configuration. For Self Managed Kafka you will need to supply blocks for type VPC_SUBNET and VPC_SECURITY_GROUP..
    uri:
      The URI for this configuration. For type VPC_SUBNET the value should be subnet:subnet_id where subnet_id is the value you would find in an aws_subnet resource's id attribute. For type VPC_SECURITY_GROUP the value should be security_group:security_group_id where security_group_id is the value you would find in an aws_security_group resource's id attribute.
  DOC

  type = object({
    type = string
    uri  = string
  })

  validation {
    condition = anytrue([
      var.source_access_configuration.type == "VPC_SUBNET" ? can(regex("^subnet:subnet-\\w+", var.source_access_configuration.uri)) : false,
      var.source_access_configuration.type == "VPC_SECURITY_GROUP" ? can(regex("^security_group:sg-\\w+", var.source_access_configuration.uri)) : false
      || contains(["VIRTUAL_HOST", "BASIC_AUTH"], var.source_access_configuration.type)
    ])
    error_message = "Error! valid values for type are VPC_SUBNET,VPC_SECURITY_GROUP,VIRTUAL_HOST,BASIC_AUTH."
  }
}