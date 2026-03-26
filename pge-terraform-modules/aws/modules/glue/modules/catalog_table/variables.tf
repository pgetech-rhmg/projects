variable "name" {
  description = "Name of the table. For Hive compatibility, this must be entirely lowercase"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9_]*$", var.name))
    error_message = "Error! The acceptable characters are lowercase letters, numbers, and the underscore character."
  }
}

variable "database_name" {
  description = "Name of the metadata database where the table metadata resides. For Hive compatibility, this must be all lowercase"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9_]*$", var.database_name))
    error_message = "Error! The acceptable characters are lowercase letters, numbers, and the underscore character."
  }
}

variable "catalog_id" {
  description = "ID of the Glue Catalog and database to create the table in. If omitted, this defaults to the AWS Account ID plus the database name"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the table"
  type        = string
  default     = null
}

variable "owner" {
  description = "Owner of the table"
  type        = string
  default     = null
}

variable "retention" {
  description = " Retention time for this table"
  type        = string
  default     = null
}

variable "table_type" {
  description = "Type of this table (EXTERNAL_TABLE, VIRTUAL_VIEW, etc.). While optional, some Athena DDL queries such as ALTER TABLE and SHOW CREATE TABLE will fail if this argument is empty"
  type        = string
  default     = null
}

variable "view_expanded_text" {
  description = "If the table is a view, the expanded text of the view; otherwise null"
  type        = string
  default     = null
}

variable "view_original_text" {
  description = "If the table is a view, the original text of the view; otherwise null"
  type        = string
  default     = null
}

variable "parameters" {
  description = "Properties associated with this table, as a list of key-value pairs"
  type        = map(string)
  default     = null
}

variable "partition_index" {
  description = "Configuration block for a maximum of 3 partition indexes"
  type        = list(map(string))
  default     = []
}

variable "partition_keys" {
  description = "Configuration block of columns by which the table is partitioned. Only primitive types are supported as partition keys"
  type        = list(map(string))
  default     = []
}

variable "storage_descriptor" {
  description = "Configuration block for information about the physical storage of this table"
  type        = list(any)
  default     = []
}

variable "target_table" {
  description = "Configuration block of a target table for resource linking"
  type        = list(map(string))
  default     = []
}