# Account related variables
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

# Lambda specific variables

variable "name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
}

variable "image_uri" {
  description = "Location of the image in URI format"
  type        = string
}

variable "environment_variables" {
  description = "Map of environment variables that are accessible from the function code during execution"
  type        = map(string)
  default     = {}
}

# VPC networking variables
variable "subnet_id1_name" {
  type        = string
  description = "The name given in the parameter store for the subnet id 1"
}

variable "subnet_id2_name" {
  type        = string
  description = "The name given in the parameter store for the subnet id 2"
}

variable "subnet_id3_name" {
  type        = string
  description = "The name given in the parameter store for the subnet id 3"
}

variable "vpc_id_name" {
  type        = string
  description = "The name given in the parameter store for the vpc id"
}


# Required tags
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
# Optional tags
variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

# IAM role variables
variable "iam_aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "iam_policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
}
variable "enable_ephemeral_storage" {
  description = "Flag to enable ephemeral storage"
  type        = bool
  default     = false
}

variable "ephemeral_storage_size" {
  description = "The size of the ephemeral storage in MB"
  type        = number
  default     = 512
}