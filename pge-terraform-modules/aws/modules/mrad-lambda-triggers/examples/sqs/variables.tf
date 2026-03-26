variable "TFC_CONFIGURATION_VERSION_GIT_BRANCH" {
  type    = string
  default = "development"
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_account" {
  type        = string
  description = "The aws account/environment (Dev/Test/QA/Prod)"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}
