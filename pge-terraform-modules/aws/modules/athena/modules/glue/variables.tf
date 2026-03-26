variable "glue_database_name" {
  type        = string
  description = "Name of the Glue database to create or reference for Athena queries."
}

variable "glue_table_name" {
  type        = string
  description = "Name of the Glue table to create or reference within the specified database."
}

variable "data_bucket" {
  type        = string
  description = "S3 bucket containing the data files used by the Glue external table."
}

variable "data_prefix" {
  type        = string
  description = "S3 prefix (folder path) where the Glue table's data is stored."
}

variable "columns" {
  type = list(object({
    name = string
    type = string
  }))
  description = "List of column definitions for the Glue table schema, including column name and data type."
}

variable "input_format" {
  type        = string
  default     = "org.apache.hadoop.mapred.TextInputFormat"
  description = "Input format class used by the Glue table to read data from S3."
}

variable "output_format" {
  type        = string
  default     = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
  description = "Output format class used by the Glue table when writing data."
}

variable "serialization_library" {
  type        = string
  default     = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
  description = "SerDe library used to serialize and deserialize table data."
}

variable "serde_parameters" {
  type = map(string)
  default = {
    "field.delim" = ","
  }
  description = "Key-value parameters passed to the SerDe library, such as field delimiters."
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}