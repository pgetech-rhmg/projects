# Variables for dynamodb kinesis streaming

variable "stream_arn" {
  description = "The ARN for a Kinesis data stream. This must exist in the same account and region as the DynamoDB table."
  type        = string
  validation {
    condition = anytrue([
      var.stream_arn == null,
      can(regex("^arn:aws:kinesis:\\w+(?:-\\w+)+:[[:digit:]]{12}:stream/([a-zA-Z0-9])+(.*)$", var.stream_arn))
    ])
    error_message = "Amazon Kinesis Data Stream ARN is required and allowed format of the Amazon Kinesis Data Stream ARN is arn:aws:kinesis:<region>:<account-id>:stream/<deliverystream-name>."
  }
}

variable "table_name" {
  description = "Dynamodb table name (space is not allowed)."
  type        = string
  validation {
    condition = alltrue([
      can(regex("([a-zA-Z0-9-_.]+)", var.table_name)),
      length(var.table_name) >= 3 && length(var.table_name) <= 255
    ])
    error_message = "Table names and index names must be between 3 and 255 characters long, and can contain only the following characters:a-z,A-Z,0-9,_(underscore),-(dash),.(dot)."
  }
}