#
# Filename    : aws/modules/mrad-lambda/examples/First-Example-Lambda/variables.tf
# Date        : 18 April 2023
# Author      : MRAD (mrad@pge.com)
# Description : variables for the mrad lambda example
#

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

variable "aws_account" {
  type        = string
  description = "Aws account name, dev, qa, test, production. "
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

variable "service" {
  type = list(string)
}

variable "archive_path" {
  type        = string
  description = "The path to the Lambda for the archive provider"
  default     = ""
}

variable "AppID" {
  type = string
}

variable "DataClassification" {
  type = string
}

variable "Environment" {
  type = string
}

variable "CRIS" {
  type = string
}

variable "Notify" {
  type = list(string)
}

variable "Owner" {
  type = list(string)
}

variable "Compliance" {
  type = list(string)
}

variable "optional_tags" {
  description = "Optional_tags."
  type        = map(string)
  default     = {}
}

variable "partner" {
  type        = string
  description = "partner team name"
  default     = "MRAD"
}

variable "TFC_CONFIGURATION_VERSION_GIT_BRANCH" {
  type = string
}

