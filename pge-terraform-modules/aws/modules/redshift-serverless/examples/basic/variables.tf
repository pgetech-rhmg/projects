variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

# Variables for Tags
variable "optional_tags" {
  description = "Optional additional tags"
  type        = map(string)
  default     = {}
}

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID. Format = APP-####"
  type        = number
}

variable "Environment" {
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
  type        = string
}

variable "DataClassification" {
  description = "Classification of data - can be made conditionally required based on Compliance. One of the following: Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)"
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
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Lead"
  type        = list(string)
}

variable "Compliance" {
  description = "Identify assets with compliance requirements (SOX, HIPAA, CCPA, etc.)"
  type        = list(string)
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
  default     = 0
}

# SSM Parameters for VPC resources
variable "ssm_parameter_subnet_id1" {
  description = "Enter the value of subnet id1 stored in SSM parameter"
  type        = string
}

variable "ssm_parameter_subnet_id2" {
  description = "Enter the value of subnet id2 stored in SSM parameter"
  type        = string
}

variable "ssm_parameter_subnet_id3" {
  description = "Enter the value of subnet id3 stored in SSM parameter"
  type        = string
}

variable "parameter_vpc_id_name" {
  description = "ID of VPC stored in aws_ssm_parameter"
  type        = string
}

# Redshift Serverless Configuration
variable "name" {
  description = "Base name for the Redshift Serverless resources"
  type        = string
}

variable "admin_username" {
  description = "Admin username for Redshift Serverless"
  type        = string
  default     = "admin"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "dev"
}

variable "base_capacity" {
  description = "Base capacity in RPUs"
  type        = number
  default     = 128
}

variable "max_capacity" {
  description = "Maximum capacity in RPUs"
  type        = number
  default     = null
}

variable "log_exports" {
  description = "Types of logs to export"
  type        = list(string)
  default     = []
}

variable "enhanced_vpc_routing" {
  description = "Enable enhanced VPC routing"
  type        = bool
  default     = false
}
