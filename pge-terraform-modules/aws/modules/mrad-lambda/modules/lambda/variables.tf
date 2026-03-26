#
# Filename    : modules/mrad-lambda/variables.tf
# Date        : 18 April 2023
# Author      : MRAD (mrad@pge.com)
# Description : variables for the mrad lambda module
#

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "aws_role" {
  type = string
}

variable "kms_role" {
  type = string
}

variable "lambda_name" {
  type        = string
  description = "The name of the Lambda"
}

variable "runtime" {
  type        = string
  description = "The runtime the Lambda is executing in"
  default     = "nodejs14.x"
}

variable "handler" {
  type        = string
  description = "Where the handler function lives"
  default     = "src/index.handler"
}

variable "layers" {
  type        = list(string)
  description = "Layer that the lambda contains; default gives git"
  default     = ["arn:aws:lambda:us-west-2:553035198032:layer:git:6"]
}

variable "envvars" {
  type        = map(string)
  description = "Environment variables, like github tokens"
  default     = { "DEFAULT_ENVARS" = "TRUE" }
}

variable "aws_account" {
  type        = string
  description = "Aws account name, dev, qa, test, production. "
}

variable "timeout" {
  type        = number
  description = "Timeout for the Lambda Function"
  default     = 60
}

variable "memory" {
  type        = number
  description = "Memory for the Lambda Function"
  default     = 1024
}

variable "tracing_enabled" {
  type        = bool
  description = "Enable xray tracing"
  default     = true
}

variable "archive_path" {
  type        = string
  description = "The path to the Lambda for the archive provider"
}

variable "subnet_qualifier" {
  type        = map(any)
  description = "The subnet qualifier"
  default     = { Dev = "Dev-2", Test = "Test-2", QA = "QA", Prod = "Prod" }
}

variable "maximum_retry_attempts" {
  type        = number
  description = "Maximum number of times to retry when the function returns an error. Valid values between 0 and 2. Defaults to 2."
  default     = 2
}

variable "additional_security_groups" {
  type        = list(string)
  description = "Any additional security groups to be added to the Lambda Function"
  default     = []
}

variable "service" {
  type = list(string)
}

variable "optional_tags" {
  description = "Optional tags"
  type        = map(string)
  default     = {}
}

variable "partner" {
  type        = string
  description = "partner team name"
  default     = "MRAD"
}

variable "subnet1" {
  type        = string
  description = "subnet1 name"
  default     = ""
}

variable "subnet2" {
  type        = string
  description = "subnet2 name"
  default     = ""
}

variable "subnet3" {
  type        = string
  description = "subnet3 name"
  default     = ""
}

variable "sg_name" {
  type        = string
  description = "security group name"
  default     = "terraform-template-lambda-sg"
}

variable "TFC_CONFIGURATION_VERSION_GIT_BRANCH" {
  type = string
}

variable "kms_key_arn" {
  type        = string
  description = "kms key arn used to encrypt lambda environment variables"
  default     = null
}

variable "dead_letter_queue_arn" {
  description = "ARN of an SNS topic or SQS queue to notify when an invocation fails."
  type        = string
  default     = null
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}
