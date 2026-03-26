variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "optional_tags" {
  description = "Optional_tags for the slr resource"
  type        = map(string)
  default     = {}
}

variable "aws_service_names" {
  description = "List of AWS Service Names for which service-linked roles will be created"
  type        = set(string)
}

variable "description" {
  description = "Description of the role"
  type        = string
  default     = "IAM Role created by pge_team = ccoe-tf-developers"
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

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}