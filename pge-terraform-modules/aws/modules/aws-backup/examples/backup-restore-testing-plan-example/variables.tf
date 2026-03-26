variable "account_num" {
  description = "Target AWS account number, mandatory. "
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}


####################################################
# Variables for Tags
####################################################

#Variables forTag
variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
}


variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "optional_tags" {
  description = "optional_tags."
  type        = map(string)
  default     = {}
}

###########################################################
# variables for Lambda
###########################################################

variable "name" {
  description = "Unique name for your Lambda Function "
  type        = string
}
 
variable "restore_iam_aws_service" {
  description = "Aws service of the backup restore IAM role"
  type        = list(string)
}
variable "policy_arns_list" {
  description = "A list of managed IAM policies to attach to the IAM role"
  type        = list(string)
  default     = []
}

###### variables for restore testing #########

variable "algorithm" {
  description = "algorithm used for selecting recovery points"
  type        = string
  default     = "RANDOM_WITHIN_WINDOW"
}

variable "recovery_point_types" {
  description = "types of recovery points to include in the selection."
  type        = list(string)
  default     = ["SNAPSHOT"]
}

variable "recovery_point_types_efs" {
  description = "types of recovery points to include in the selection."
  type        = list(string)
  default     = ["CONTINUOUS"]
}

variable "include_vaults" {
  description = "An array of vaults to be included."
  type        = list(string)
  default     = []
}

variable "schedule_expression" {
  description = "A CRON expression specifying when AWS Backup initiates a restore testing plan"
  type        = string
  default     = "cron(0 5 ? * * *)" # Daily 5 AM UTC
}

variable "resource_selection_name_s3" {
  description = "The name of the backup restore testing selection."
  type        = string
}
 
variable "resource_type_s3" {
  description = "The type of the protected resource."
  type        = string
}

variable "restore_plan_name_s3" {
  description = "Name of the restore plan  to create"
  type        = string
  validation {
    condition     = (length(var.restore_plan_name_s3) > 0)
    error_message = "Plan name cannot be empty."
  }
}

variable "resource_arns" {
  description = " The ARNs for the protected resources."
  type        = list(string)
}

variable "validation_window_hours" {
  description = "The amount of hours available to run a validation script on the data"
  type        = number
  default     = 24
}