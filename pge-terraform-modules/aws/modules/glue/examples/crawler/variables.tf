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

#KMS role

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

#Variables for tags
variable "optional_tags" {
  description = "optional_tags"
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
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

#Variables for crawler
variable "name" {
  description = "The name you assign to the Glue resources. It must be unique in your account."
  type        = string
}

variable "glue_crawler_database_name" {
  description = "Glue database where results are written."
  type        = string
}

variable "glue_crawler_table_prefix_s3" {
  description = "The table prefix used for catalog tables that are created."
  type        = string
}

variable "glue_crawler_table_prefix_dynamodb" {
  description = "The table prefix used for catalog tables that are created."
  type        = string
}

variable "glue_crawler_table_prefix_s3_dynamodb" {
  description = "The table prefix used for catalog tables that are created."
  type        = string
}

variable "glue_crawler_schedule" {
  description = "A cron expression used to specify the schedule. For more information, see Time-Based Schedules for Jobs and Crawlers."
  type        = string
}

variable "glue_crawler_schema_change_policy" {
  description = "Policy for the crawler's update and deletion behavior."
  type        = map(string)
}


variable "glue_crawler_lineage_configuration" {
  description = "Specifies data lineage configuration settings for the crawler. "
  type        = map(string)
}

variable "glue_crawler_recrawl_policy" {
  description = "A policy that specifies whether to crawl the entire dataset again, or to crawl only folders that were added since the last crawler run."
  type        = map(string)
}

variable "s3_target" {
  description = "List of nested Amazon S3 target arguments."
  type        = list(any)
}

variable "dynamodb_target" {
  description = "List of nested DynamoDB target arguments."
  type        = list(map(string))
}

#Variables for iam
variable "aws_service" {
  description = "A list of AWS services allowed to assume this role.  Required if the trusted_aws_principals variable is not provided."
  type        = list(string)
}

variable "policy_arns" {
  description = "A list of managed IAM policies to attach to the IAM role"
  type        = list(string)
}

#Variables for lakeformation
variable "permissions" {
  description = "List of permissions granted to the principal."
  type        = list(string)
}

variable "database_name" {
  description = "List of permissions granted to the principal."
  type        = string
}

variable "database_catalog_id" {
  description = "List of permissions granted to the principal."
  type        = string
}

