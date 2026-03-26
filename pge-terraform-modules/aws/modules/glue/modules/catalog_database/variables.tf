variable "name" {
  description = "Name of the database. The acceptable characters are lowercase letters, numbers, and the underscore character"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9_]*$", var.name))
    error_message = "Error! The acceptable characters are lowercase letters, numbers, and the underscore character."
  }
}

variable "catalog_id" {
  description = "ID of the Glue Catalog to create the database in. If omitted, this defaults to the AWS Account ID"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the database"
  type        = string
  default     = null
}

variable "location_uri" {
  description = "Location of the database (for example, an HDFS path)"
  type        = string
  default     = null
}

variable "parameters" {
  description = "List of key-value pairs that define parameters and properties of the database"
  type        = map(string)
  default     = {}
}

variable "target_database" {
  description = "Configuration block for a target database for resource linking."
  type        = list(map(string))
  default     = []
}

variable "create_table_default_permission" {
  description = "Creates a set of default permissions on the table for principals."
  type        = list(any)
  default     = []
}