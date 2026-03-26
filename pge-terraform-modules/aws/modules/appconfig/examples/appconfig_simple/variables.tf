variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

# KMS vars
variable "kms_name" {
  type        = string
  description = "KMS key name"
}

variable "kms_description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console."
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}


# Application vars
variable "name" {
  description = "The name of the AppConfig application."
  type        = string
  default     = ""
}

variable "description" {
  description = "The description of the AppConfig application."
  type        = string
  default     = null
}

# Configuration profile vars
variable "config_profile_name" {
  description = "The name of the AppConfig configuration profile."
  type        = string
}

variable "config_profile_description" {
  description = "The description of the AppConfig configuration profile."
  type        = string
}

# Environment
variable "env_name" {
  description = "The name of the AppConfig environment."
  type        = string
}

variable "env_description" {
  description = "The description of the AppConfig environment."
  type        = string
  default     = null
}

variable "env_monitors" {
  description = "A map of monitors for your deployment."
  type        = set(any)
  default     = []
}

# Config content
variable "hosted_config_description" {
  description = "Description of the configuration. Forced new resource."
  type        = string
  default     = null
}

variable "hosted_config_content" {
  description = "Content of the configuration or the configuration data"
  type        = string
}

variable "hosted_config_content_type" {
  description = "Standard MIME type describing the format of the configuration content"
  type        = string
}

# Required PGE tags
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

# Optional_tags
variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

