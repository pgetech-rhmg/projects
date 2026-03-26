variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

#catalog_database
variable "name" {
  description = "Name of the database. The acceptable characters are lowercase letters, numbers, and the underscore character"
  type        = string
}

variable "description" {
  description = "Description of the database"
  type        = string
}

variable "create_table_default_permission" {
  description = "Creates a set of default permissions on the table for principals."
  type        = any
}

#Catalog_table
variable "table_type" {
  description = "Type of this table (EXTERNAL_TABLE, VIRTUAL_VIEW, etc.). While optional, some Athena DDL queries such as ALTER TABLE and SHOW CREATE TABLE will fail if this argument is empty"
  type        = string
}

variable "parameters" {
  description = "Properties associated with this table, as a list of key-value pairs"
  type        = map(string)
}

variable "partition_keys" {
  description = "Configuration block of columns by which the table is partitioned. Only primitive types are supported as partition keys"
  type        = list(map(string))
}

variable "storage_descriptor" {
  description = "Configuration block for information about the physical storage of this table"
  type        = list(any)
}


variable "partition_index_name" {
  description = "Name of the partition index"
  type        = string
}

variable "partition_index_keys" {
  description = "Keys for the partition index"
  type        = list(string)
}

#variables for  partition
variable "glue_partition_values" {
  description = "The values that define the partition."
  type        = list(string)
}

variable "location" {
  description = "The physical location of the table. By default this takes the form of the warehouse location."
  type        = string
}

variable "input_format" {
  description = "The input format: SequenceFileInputFormat (binary), or TextInputFormat, or a custom format."
  type        = string
}

variable "output_format" {
  description = "The output format: SequenceFileOutputFormat (binary), or IgnoreKeyTextOutputFormat, or a custom format."
  type        = string
}

variable "compressed" {
  description = "True if the data in the table is compressed, or False if not."
  type        = string
}

variable "stored_as_sub_directories" {
  description = "True if the table data is stored in subdirectories, or False if not."
  type        = string
}

variable "partition_parameters" {
  description = "User-supplied properties in key-value form."
  type        = map(string)
}

variable "columns_name_1" {
  description = "The name of the Column."
  type        = string
}

variable "columns_type_1" {
  description = "The datatype of data in the Column."
  type        = string
}

variable "columns_name_2" {
  description = "The name of the Column."
  type        = string
}

variable "columns_type_2" {
  description = "The datatype of data in the Column."
  type        = string
}

variable "columns_name_3" {
  description = "The name of the Column."
  type        = string
}

variable "columns_type_3" {
  description = "The datatype of data in the Column."
  type        = string
}
variable "columns_name_4" {
  description = "The name of the Column."
  type        = string
}

variable "columns_type_4" {
  description = "The datatype of data in the Column."
  type        = string
}

variable "ser_de_info_name" {
  description = "Name of the SerDe."
  type        = string
}

variable "ser_de_info_serializationLib" {
  description = "Usually the class that implements the SerDe."
  type        = string
}

variable "ser_de_info_parameters" {
  description = "A map of initialization parameters for the SerDe, in key-value form."
  type        = map(string)
}

#variables for  user_defined_function
variable "function_name" {
  description = "The name of the function."
  type        = string
}

variable "class_name" {
  description = "The Java class that contains the function code."
  type        = string
}

variable "owner_name" {
  description = "The owner of the function."
  type        = string
}

variable "owner_type" {
  description = "The owner type. can be one of USER, ROLE, and GROUP."
  type        = string
}

variable "resource_type" {
  description = "The type of the resource."
  type        = string
}

variable "uri" {
  description = "The URI for accessing the resource."
  type        = string
}