######## TAGS (PGE STANDARD) ########

variable "AppID" {
  type        = string
  description = "Application ID tag used for resource identification."
}

variable "Environment" {
  type        = string
  description = "Environment tag indicating deployment stage (e.g., Dev, QA, Prod)."
}

variable "DataClassification" {
  type        = string
  description = "Data classification level applied for compliance and governance."
}

variable "CRIS" {
  type        = string
  description = "CRIS identifier used for compliance, governance, and tracking."
}

variable "Notify" {
  type        = list(string)
  description = "List of email addresses or contacts to notify for resource events."
}

variable "Owner" {
  type        = list(string)
  description = "List of owners responsible for the lifecycle of this resource."
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance frameworks or standards applicable to this resource."
}

variable "Order" {
  type        = number
  description = "Order or priority tag used for resource grouping and sorting."
}

######## AWS + MODULE VARIABLES ########

variable "aws_role" {
  type        = string
  description = "IAM role name used for assuming into the target AWS account."
}

variable "aws_region" {
  type        = string
  description = "AWS region where resources will be deployed."
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}


variable "athena_workgroup_name" {
  type        = string
  description = "Name of the Athena Workgroup to be created."
}

variable "output_location" {
  type        = string
  description = "S3 path where Athena query results will be stored (e.g., s3://bucket/prefix/)."
}

variable "glue_database_name" {
  type        = string
  description = "Name of the Glue database to create or reference."
}

variable "glue_table_name" {
  type        = string
  description = "Name of the Glue table to create or reference."
}

variable "data_bucket" {
  type        = string
  description = "S3 bucket containing the data for the Glue table."
}

variable "data_prefix" {
  type        = string
  description = "S3 prefix (folder path) where the Glue table data resides."
}

variable "columns" {
  type = list(object({
    name = string
    type = string
  }))
  description = "List of column definitions for the Glue table schema, including name and data type."
}
