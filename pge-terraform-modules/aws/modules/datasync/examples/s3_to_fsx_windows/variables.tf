variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "aws_role" {
  type = string
}

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

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
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

variable "cloudwatch_log_group_arn" {
  type        = string
  description = "The ARN of the CloudWatch log group to which to send the logs."
  default     = null
}

variable "s3_role_name" {
  type        = string
  description = "Name of the IAM role to be created for DataSync to access S3 bucket."
}

variable "aws_service" {
  type        = list(string)
  description = "The AWS service for which the role is being created."
}

variable "bucket_name" {
  type        = string
  description = "Name of the source S3 bucket."
}

variable "fsx_location_arn" {
  type        = string
  description = "The ARN of the FSx for Windows file system."
}

variable "fsx_user" {
  type        = string
  description = "The FSx for Windows file system user."
}

variable "fsx_password" {
  type        = string
  description = "The FSx for Windows file system password."
}

variable "s3_location_subdirectory" {
  type        = string
  description = "The subdirectory in the S3 bucket."
}

variable "domain" {
  type        = string
  description = "The domain of the FSx for Windows file system."
}

variable "posix_permissions" {
  type        = string
  description = "The POSIX permissions to set on the FSx for Windows file system."
  default     = "NONE"
}

variable "gid" {
  type        = string
  description = "The group ID to set on the FSx for Windows file system."
  default     = "NONE"
}

variable "uid" {
  type        = string
  description = "The user ID to set on the FSx for Windows file system."
  default     = "NONE"
}

variable "task_name" {
  type        = string
  description = "The name of the DataSync task."
}