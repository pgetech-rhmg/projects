# Variables for dynamodb global table

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

variable "global_replica_region_name" {
  description = "Defines the global replica region for the dynamodb global replica. The Underlying DynamoDB Table. At least 1 replica must be defined.This will be the replica of the primary region."
  type        = string
}

variable "primary_aws_region" {
  description = "Defines the primary region of the dynamodb table."
  type        = string

}