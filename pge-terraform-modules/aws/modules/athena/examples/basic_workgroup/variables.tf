variable "results_bucket_name" {
  type        = string
  description = "Name of the S3 bucket used to store Athena query results."
}

variable "athena_workgroup_name" {
  type        = string
  description = "Name of the Athena Workgroup to be created."
}

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
