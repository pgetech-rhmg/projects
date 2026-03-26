# Variables for assume_role used in terraform.tf

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_role" {
  description = "AWS role"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

# Variables for tags

variable "optional_tags" {
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

# Supporting resource variables
variable "ssm_parameter_vpc_id" {
  description = "SSM parameter name storing the VPC ID for private subnets (no internet gateway)"
  type        = string
}

variable "ssm_parameter_subnet_id1" {
  description = "SSM parameter name storing private subnet ID 1"
  type        = string
}

variable "ssm_parameter_subnet_id2" {
  description = "SSM parameter name storing private subnet ID 2"
  type        = string
}

variable "ssm_parameter_subnet_id3" {
  description = "SSM parameter name storing private subnet ID 3"
  type        = string
}

# IAM variables
variable "role_service" {
  description = "AWS service for the IAM role"
  type        = list(string)
}

# VPC Endpoint variables
variable "appstream_service_name" {
  description = "AppStream streaming service name for VPC endpoint"
  type        = string
  default     = "com.amazonaws.us-west-2.appstream.streaming"
}

# AppStream variables
variable "name" {
  description = "Unique name for the AppStream resources"
  type        = string
}

variable "description" {
  description = "Description to display"
  type        = string
}

variable "display_name" {
  description = "Human-readable friendly name for the AppStream resources"
  type        = string
}

variable "domain_join_info" {
  description = "Configuration block for joining instances to Microsoft Active Directory domain"
  type = object({
    directory_name                         = string
    organizational_unit_distinguished_name = optional(string)
  })
  default = null
}

# Fleet variables
variable "instance_type" {
  description = "Instance type to use when launching fleet instances"
  type        = string
}

variable "fleet_type" {
  description = "Fleet type. Valid values are: ON_DEMAND, ALWAYS_ON, ELASTIC"
  type        = string
}

variable "desired_instances" {
  description = "Desired number of streaming instances"
  type        = number
}

variable "image_name" {
  description = "Name of the image used to create the fleet"
  type        = string
}