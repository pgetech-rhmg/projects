#Variables for provider 
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

#Variables for kms
variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

#variables for Tags
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
  description = "Compliance Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}


#variables for aws_iam_role
variable "role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "iam_policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
}

# variables for feature group
variable "name" {
  description = "The name of the Feature Group. The name must be unique within an AWS Region in an AWS account."
  type        = string
}

variable "record_identifier_feature_name" {
  description = "The name of the Feature whose value uniquely identifies a Record defined in the Feature Store. Only the latest record per identifier value will be stored in the Online Store."
  type        = string
}

variable "event_time_feature_name" {
  description = "The name of the feature that stores the EventTime of a Record in a Feature Group."
  type        = string
}

variable "feature_definition" {
  description = "A list of Feature names and types. See Feature Definition Below."
  type        = list(any)
}

variable "s3_uri" {
  description = "The S3 URI, or location in Amazon S3, of OfflineStore."
  type        = string
}

variable "database" {
  description = "The name of the Glue table database."
  type        = string
}

variable "table_name" {
  description = "The name of the Glue table."
  type        = string
}

variable "catalog" {
  description = "The name of the Glue table catalog."
  type        = string
}