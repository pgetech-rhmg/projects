#Variables for provider

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

# Variables for tags

variable "optional_tags" {
  description = "Optional tags"
  type        = map(string)
  default     = {}
}

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
  type        = string
}

variable "DataClassification" {
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
  type        = string
}

variable "CRIS" {
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
  type        = string
}

variable "Notify" {
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
  type        = list(string)
}

variable "Owner" {
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
  type        = list(string)
}

variable "Compliance" {
  description = "Compliance Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

#Common variable for name

variable "name" {
  description = "A common name for resources."
  type        = string
}

#Variables for glue ml transform

variable "glue_database_name" {
  description = "A database name in the AWS Glue Data Catalog."
  type        = string
}

variable "table_name" {
  description = "A table name in the AWS Glue Data Catalog."
  type        = string
}

variable "transform_type" {
  description = "The type of machine learning transform."
  type        = string
}

variable "accuracy_cost_trade_off" {
  description = "The value that is selected when tuning your transform for a balance between accuracy and cost."
  type        = number
}

variable "precision_recall_trade_off" {
  description = "The value selected when tuning your transform for a balance between precision and recall."
  type        = number
}

variable "primary_key_column_name" {
  description = "The name of a column that uniquely identifies rows in the source table."
  type        = string
}

variable "glue_version" {
  description = "The version of glue to use, for example 1.0. For information about available versions."
  type        = string
}

variable "max_capacity" {
  description = "The number of AWS Glue data processing units (DPUs) that are allocated to task runs for this transform. You can allocate from 2 to 100 DPUs; the default is 10. max_capacity is a mutually exclusive option with number_of_workers and worker_type."
  type        = number
}

variable "max_retries" {
  description = "The maximum number of times to retry this ML Transform if it fails."
  type        = number
}

variable "worker_type" {
  description = "The type of predefined worker that is allocated when an ML Transform runs. Accepts a value of Standard, G.1X, or G.2X. Required with number_of_workers."
  type        = string
}

variable "number_of_workers" {
  description = "The number of workers of a defined worker_type that are allocated when an ML Transform runs. Required with worker_type."
  type        = number
}

# Variables for IAM

variable "role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "iam_policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
}

# Variables for AWS Lake Formation

variable "permissions" {
  description = "List of permissions granted to the principal."
  type        = list(string)
}

variable "database_name" {
  description = "Name of the database."
  type        = string
}

variable "database_catalog_id" {
  description = "Catalog id of the database."
  type        = string
}