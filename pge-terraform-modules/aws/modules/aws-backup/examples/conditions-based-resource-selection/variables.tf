variable "account_num" {
  description = "Target AWS account number, mandatory. "
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume."
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
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
# variables for Backup vault
###########################################################

variable "vault_name" {
  description = "Name of the backup vault to create"
  type        = string
}

###########################################################
# variables for Backup plan
###########################################################

variable "aws_backup_plan_name" {
  description = "The display name of a backup plan"
  type        = string
}

variable "aws_backup_plan_rule" {
  description = "Enable Windows VSS backup option and create a VSS Windows backup"
  type        = list(any)
}

###########################################################
# variables for Backup Selection
###########################################################

variable "backup_selection_name" {
  description = "The display name of a resource selection document."
  type        = string
}

###########################################################
# variables for IAM role
###########################################################


variable "iam_role_name" {
  description = "IAM Role Name"
  type        = string
  default     = null
}

variable "aws_service" {
  description = "A list of AWS services allowed to assume this role.  Required if the trusted_aws_principals variable is not provided."
  type        = list(string)
  validation {
    condition     = length(var.aws_service) == length(distinct(var.aws_service))
    error_message = "All elements of aws_service must be unique."
  }
}

variable "policy_arns_list" {
  description = "A list of managed IAM policies to attach to the IAM role"
  type        = list(string)
  default     = []
}

###########################################################

### KMS ###

variable "create_kms_key" {
  description = "Set it false if a new KMS key to be generated"
  type        = bool
  default     = true
}
