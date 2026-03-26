#variables for glue_partition_index
variable "partition_table_name" {
  description = "Name of the table. For Hive compatibility, this must be entirely lowercase."
  type        = string
}

variable "partition_database_name" {
  description = "Name of the metadata database where the table metadata resides. For Hive compatibility, this must be all lowercase."
  type        = string
}

variable "partition_index" {
  description = "Configuration block for a partition index."
  type        = list(any)
}
variable "timeouts" {
  description = "set timeouts for partition_index"
  type        = map(string)
  default     = {}
}

variable "partition_catalog_id" {
  description = "The catalog ID where the table resides."
  type        = string
  default     = null
}