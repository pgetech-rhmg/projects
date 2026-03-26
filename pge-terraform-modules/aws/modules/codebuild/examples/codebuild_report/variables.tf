variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

#variables for codebuild_report_group
variable "codebuild_rg_name" {
  description = "The name of Report Group"
  type        = string
}

variable "codebuild_rg_type" {
  description = "The type of the Report Group"
  type        = string
}

variable "codebuild_rg_delete_reports" {
  description = " If true, deletes any reports that belong to a report group before deleting the report group"
  type        = bool
}

variable "codebuild_rg_export_type" {
  description = "The export configuration type"
  type        = string
}

variable "codebuild_rg_packaging" {
  description = "The type of build output artifact to create. Valid values are: NONE and ZIP."
  type        = string
}


variable "codebuild_rg_path" {
  description = "The path to the exported report's raw data results"
  type        = string
}

variable "policy_file_name" {
  description = "Valid JSON document representing a resource policy"
  type        = string
}

#variables for S3-bucket
variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

#variables for kms_key
variable "kms_name" {
  type        = string
  description = "Unique name"
}

variable "kms_description" {
  type        = string
  description = "The description of the key as viewed in AWS console."
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

#variables for Tags
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