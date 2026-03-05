###############################################################################
# Variables
###############################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "environment" {
  description = "Environment (dev, prod, etc.)"
  type        = string
}

variable "appid" {
  description = "Application ID"
  type        = string
}

variable "compliance" {
  description = "Compliance classification"
  type        = string
}

variable "cris" {
  description = "CRIS value"
  type        = string
}

variable "dataclassification" {
  description = "Data classification"
  type        = string
}

variable "notify" {
  description = "Notification contact"
  type        = string
}

variable "order" {
  description = "Order number"
  type        = string
}

variable "owner" {
  description = "Owner"
  type        = string
}

variable "access_log_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = ""
}

variable "enable_access_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = false
}

variable "oidc_provider_arn" {
  description = "ARN of OIDC provider for Azure/ADO federation (leave empty if not using)"
  type        = string
  default     = ""
}

variable "oidc_audience" {
  description = "OIDC audience values for federation"
  type        = list(string)
  default     = []
}

variable "allow_epic_local_deployment" {
  description = "Allow EPIC service role to deploy resources in its own account"
  type        = bool
  default     = false
}
