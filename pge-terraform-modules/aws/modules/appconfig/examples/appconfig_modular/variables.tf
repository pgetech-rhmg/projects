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
  description = "KMS key name for S3 bucket encryption"
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

# Environment
variable "monitors" {
  description = "A set of CloudWatch alarms to monitor during the deployment process."
  type        = set(any)
  default     = []
}

variable "env_name" {
  description = "The name of the environment"
  type        = string
}

variable "env_description" {
  description = "A description of the environment."
  type        = string
  default     = null
}

# Configuration profile vars
variable "config_profile_name" {
  description = "The name of the AppConfig configuration profile."
  type        = string
}

variable "config_profile_desc" {
  description = "The description of the AppConfig configuration profile."
  type        = string
}

# Config content
variable "hosted_config_description" {
  description = "A description of the configuration."
  type        = string
  default     = null
}
variable "content" {
  description = "Content of the configuration or the configuration data."
  type        = string
}

# Deployment Strategy
variable "strategy_name" {
  description = "Name for the deployment strategy."
  type        = string
}

variable "strategy_description" {
  description = "Description of the deployment strategy"
  type        = string
  default     = null
}

variable "replicate_to" {
  description = "Where to save the deployment strategy."
  type        = string
  default     = "NONE"
}

variable "bake_time" {
  description = "Amount of time AWS AppConfig monitors for alarms before considering the deployment to be complete and no longer eligble for automatic rollback."
  type        = number
  default     = 0
}

variable "deployment_duration" {
  description = "Total amount of time for a deployment to last."
  type        = number
  default     = 0
}

variable "growth_type" {
  description = "Algorithm used to define how percentage grows over time."
  type        = string
  default     = "LINEAR"
}

variable "growth_factor" {
  description = "Percentage of targets to receive a deployed configuration during each interval."
  type        = number
  default     = 1
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

