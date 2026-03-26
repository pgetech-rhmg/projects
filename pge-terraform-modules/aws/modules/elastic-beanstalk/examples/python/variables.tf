variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

#Variables for tags
variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
}

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
  type        = string
}

variable "DataClassification" {
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
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
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
  type        = list(string)
}

variable "Compliance" {
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

#Common variable for name
variable "name" {
  description = "A common name for resources."
  type        = string
}

#Variables for ssm parameter
variable "ssm_parameter_vpc_id" {
  description = "Value of vpc id stored in ssm parameter."
  type        = string
}

variable "ssm_parameter_subnet_id1" {
  description = "Value of subnet id1 stored in ssm parameter."
  type        = string
}

variable "ssm_parameter_subnet_id2" {
  description = "Value of subnet id2 stored in ssm parameter."
  type        = string
}

variable "ssm_parameter_subnet_id3" {
  description = "Value of subnet id3 stored in ssm parameter."
  type        = string
}

#variables for iam role
variable "aws_service" {
  description = "A list of AWS services allowed to assume this role.  Required if the trusted_aws_principals variable is not provided."
  type        = list(string)
  default     = []
}

variable "policy_arns" {
  description = "A list of managed IAM policies arns to attach to the IAM role"
  type        = list(string)
}

#Variables for s3
variable "template_file_name" {
  description = "Policy template file in json format "
  type        = string
}

#Variables for elastic_beanstalk_environment
variable "environment_solution_stack_name" {
  description = "Elastic Beanstalk environment solution stack name"
  type        = string
}

#Variables for S3 object
variable "application_version" {
  description = "Application version deployed."
  type        = string
}

variable "application_version_source_zip" {
  description = "Application version source zip file path/name."
  type        = string
}

#Variables for application version
variable "application_version_force_delete" {
  description = "On delete, force an Application Version to be deleted when it may be in use by multiple Elastic Beanstalk Environments."
  type        = bool
}

#variables for acm
variable "acm_domain_name" {
  description = "Domain name for which the certificate should be issued."
  type        = string
}

variable "organization" {
  description = "the organisation of thr acm"
  type        = string
}

variable "private_key_algorithm" {
  description = "Name of the algorithm to use when generating the private key. Currently-supported values are: RSA, ECDSA, ED25519."
  type        = string
}

variable "allowed_uses" {
  description = " List of key usages allowed for the issued certificate."
  type        = list(string)
}

variable "validity_period_hours" {
  description = "The validity hours of the acm certificate"
  type        = number
}
