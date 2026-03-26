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

variable "create_vault_notifications" {
  description = "Change to true if vault notifications needs to be enabled"
  type        = bool
}

variable "backup_vault_events" {
  description = "An array of events that indicate the status of jobs to back up resources to the backup vault."
  type        = list(string)
}

variable "replica_vault_name" {
  description = "Name of the replica backup vault to create"
  type        = string
}

###########################################################
# variables for Backup plan
###########################################################

variable "aws_backup_plan_name" {
  description = "The display name of a backup plan"
  type        = string
}

variable "backup_rule_name" {
  description = "The display name for a backup rule"
  type        = string
}

variable "backup_rule_schedule" {
  description = "A CRON expression specifying when AWS Backup initiates a backup job."
  type        = string
}

variable "backup_rule_start_window" {
  description = "The amount of time in minutes before beginning a backup."
  type        = string
}

variable "backup_rule_completion_window" {
  description = "The amount of time in minutes AWS Backup attempts a backup before canceling the job and returning an error."
  type        = string
}

variable "backup_rule_delete_after" {
  description = "Specifies the number of days after creation that a recovery point is deleted."
  type        = string
}

variable "destination_vault_delete_after" {
  description = "Specifies the number of days after creation that a recovery point is deleted."
  type        = string
}

###########################################################
# variables for Backup Selection
###########################################################

variable "backup_selection_name" {
  description = "The display name of a resource selection document."
  type        = string
}

variable "selection_tags" {
  description = "An array of tag condition objects used to filter resources based on tags for assigning to a backup plan"
  type        = any
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
# variables for KMS
###########################################################

### KMS ###

variable "create_kms_key" {
  description = "Set it false if a new KMS key to be generated"
  type        = bool
  default     = true
}




###########################################################
# variables for SNS
###########################################################


variable "snstopic_name" {
  description = "name of the SNS topic"
  type        = string
}

variable "snstopic_display_name" {
  description = "The display name of the SNS topic"
  type        = string
}

variable "endpoint" {
  description = "Endpoint to send data to. The contents vary with the protocol"
  type        = list(string)
}

variable "protocol" {
  description = "Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application"
  type        = string
}

variable "sns_policy_file_name" {
  description = "Valid JSON document representing a resource policy"
  type        = string
}
