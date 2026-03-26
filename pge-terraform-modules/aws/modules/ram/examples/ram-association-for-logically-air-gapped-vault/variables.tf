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

variable "optional_tags" {
  description = "optional_tags."
  type        = map(string)
  default     = {}
}

###########################################################
# variables for Ram Share
###########################################################

variable "logically_air_gapped_vault_name" {
  description = "Name of the backup vault to create"
  type        = string
}

variable "max_retention_days" {
  description = "The maximum retention period that the vault retains its recovery points"
  type        = number
  default     = null
  
}

variable "min_retention_days" {
  description = "The minimum retention period that the vault retains its recovery points"
  type        = number
  default     = null
  
}

variable "share_name" {
  description = "The name for the Ram share"
  type        = string
}

variable "allow_external_principals" {
  description = "Indicates list of allowed principals to be associated with the resource share "
  type        = bool
  default     = true
}

variable "principal_ids" {
  description = "List of Account Ids for RAM Share"
  type        = list(string)
}
