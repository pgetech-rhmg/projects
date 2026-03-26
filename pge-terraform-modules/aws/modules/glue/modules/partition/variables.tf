variable "glue_partition_database_name" {
  description = " Name of the metadata database where the table metadata resides. For Hive compatibility, this must be all lowercase."
  type        = string
}

variable "glue_partition_table_name" {
  description = " Name of the table metadata resides."
  type        = string
}

variable "glue_partition_values" {
  description = " The values that define the partition."
  type        = list(string)
}

variable "glue_partition_catalog_id" {
  description = "ID of the Glue Catalog and database to create the table in. If omitted, this defaults to the AWS Account ID plus the database name."
  type        = string
  default     = null
}

variable "glue_partition_parameters" {
  description = "Properties associated with this table, as a list of key-value pairs."
  type        = map(string)
  default     = null
}

variable "glue_partition_storage_descriptor" {
  description = "A storage descriptor object containing information about the physical storage of this table."
  #As per Terraform registry data type 'map(any)' should contain elements of the same type, for the block 'storage_descriptor'
  #the variable 'glue_partition_storage_descriptor' have elements of different types and hence we have to use type 'any'.
  type    = any
  default = null
}