variable "aws_region" {
    description = "Environment(dev, prod)"
    type = string
}

variable "Optional_tags" {
  description = "Optional tags"
  type        = map(string)
  default     = {}
}

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
}


variable "aws_service" {
  description = "The AWS service that is allowed to assume this role"
  type        = list(string)
  default     = []
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance. One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
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

variable "account_id" {
    description = "AWS Account id for cross account access"
    type = string
}

# variable "new_ami_id" {
#     description = "New AMI ID to be used for updates"
#     type = string
# }

variable "excluded_instances" {
    description = "List of instance IDs to exclude"
    type = list(string)
    default = []
}

variable "excluded_asgs" {
    description = "List of ASGs IDs to exclude"
    type = list(string)
    default = []
}

variable "asg_configurations" {
    description = "Map of ASG configuratons (min, max, desired)"
    type = map(object({
        min = number
        max = number
        desired = number
    }))
    default = {}
}

variable "role_name" {
  description = "The name of the IAM role"
  type        = string
}


variable "vpc_config_security_group_ids" {
  description = "List of security group IDs for the Lambda function VPC configuration"
  type = list(string)
  default = []
}

variable "vpc_config_subnet_ids" {
  description = "List of subnet IDs for the Lambda function VPC configuration"
  type = list(string)
  default = []
}

variable "policy_arns" {
  description = "List of policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "List of ASGs IDs to exclude"
  type = string
  default = null
}

variable "trusted_aws_principals" {
  description = "The AWS principals that are allowed to assume this role"
  type        = list(string)
}


variable "description" {
  description = "Description of the role"
  type        = string
}


variable "path" {
  description = "Path to the role"
  type        = string
}
