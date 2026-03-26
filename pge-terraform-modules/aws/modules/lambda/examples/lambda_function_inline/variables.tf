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

##############################

variable "vpc_id_name" {
  type        = string
  description = "The name given in the parameter store for the vpc id"
}

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

#variables for Lambda_function
variable "logging_config" {
  description = "The logging configuration for the Lambda function."
  type = object({
    log_format            = optional(string)
    application_log_level = optional(string)
    system_log_level      = optional(string)
  })
}

variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Unique name for your Lambda Function"
  type        = string
}

variable "handler" {
  description = "Function entrypoint in your code"
  type        = string
}

variable "description" {
  description = "Description of what your Lambda Function does"
  type        = string
}

variable "runtime" {
  description = "Identifier of the function's runtime"
  type        = string
}

variable "content" {
  description = "Add only this content to the archive with source_content_filename as the filename."
  type        = string
}

variable "filename" {
  description = "Set this as the filename when using source_content."
  type        = string
}

variable "reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations"
  type        = number
  default     = -1
}

#variables for aws_lambda_iam_role
variable "iam_aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "iam_policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
}

#variables for Tags
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