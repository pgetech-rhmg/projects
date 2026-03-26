########################################
##Variables for IAM roles
########################################

#####Variables for IAM



variable "role_service_rds_auto_start_stop" {
  type        = list(string)
  description = "Aws service of the iam role"
}

variable "iam_policy_arns_rds_auto_start_stop" {
  description = "Policy arn for the iam role"
  type        = list(string)
}

########################################
## Variables for RDS Auto Start Stop
########################################

variable "rds_auto_control_service_name" {
  type        = string
  description = "RDS auto control service name"
}

variable "lambda_sg_description" {
  description = "vpc id for security group"
  type        = string
}


variable "lambda_runtime" {
  description = "Identifier of the function's runtime"
  type        = string
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
}

variable "schedule_rds_auto_start" {
  description = "Cron schedule to trigger lambda function"
  type        = string
}

variable "schedule_rds_auto_stop" {
  description = "Cron schedule to trigger lambda function"
  type        = string
}

# variable "domain" {
#   description = "The ID of the Directory Service Active Directory domain to create the instance in"
#   type        = string

# }

variable "domain_iam_role_name" {
  description = "(Required if domain is provided) The name of the IAM role to be used when making API calls to the Directory Service"
  type        = string
  default     = "rds-directoryservice-kerberos-access-role"
}





variable "user" {
  type        = string
  description = "User id for aws session"
}


variable "aws_role" {
  type        = string
  description = "Unique name for the role"
}


variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}


variable "service_name" {
  type        = string
  description = "service name to be associated with vpce"
}

#########################################
# Variables for Tags
#########################################

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

variable "optional_tags" {
  description = "Optional tags"
  type        = map(string)
  default     = {}
}

variable "Order" {
  type        = number
  description = "Order must be a  number between 7 and 9 Digits. This is used to identify the order in which the assets are created."
}
