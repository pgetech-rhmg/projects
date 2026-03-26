###############################################################################
# AWS Account
###############################################################################
variable "account_num" {
  description = "Target AWS account number"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
  default     = "CloudAdmin"
}

###############################################################################
# PG&E Required Tags
###############################################################################
variable "AppID" {
  description = "AMPS APP ID. Format: APP-#### (pass as number)"
  type        = number
}

variable "Environment" {
  description = "Dev, Test, QA, or Prod"
  type        = string
}

variable "DataClassification" {
  description = "Public, Internal, Confidential, Restricted, Privileged"
  type        = string
}

variable "CRIS" {
  description = "Cyber Risk Impact Score: High, Medium, or Low"
  type        = string
}

variable "Notify" {
  description = "List of email addresses for notifications"
  type        = list(string)
}

variable "Owner" {
  description = "Exactly 3 owners (LANID1, LANID2, LANID3)"
  type        = list(string)
}

variable "Compliance" {
  description = "List of compliance requirements: SOX, HIPAA, CCPA, BCSI, None"
  type        = list(string)
}

variable "Order" {
  description = "Order number: between 7 and 9 digits"
  type        = number
}

variable "optional_tags" {
  description = "Additional custom tags"
  type        = map(string)
  default     = {}
}

###############################################################################
# FIS Configuration
###############################################################################
variable "s3_bucket_name" {
  description = "S3 bucket name for FIS experiment logs"
  type        = string
}

variable "primary_az" {
  description = "Availability Zone for Primary SQL Server"
  type        = string
}

variable "secondary_az" {
  description = "Availability Zone for Secondary SQL Server"
  type        = string
}

variable "tertiary_az" {
  description = "Availability Zone with no database servers"
  type        = string
}

###############################################################################
# Test Harness
###############################################################################
variable "vpc_id" {
  description = "VPC ID where test harness resources will be deployed"
  type        = string
}

variable "test_subnet_id" {
  description = "Isolated subnet ID (AZ-D) where test resources will be deployed"
  type        = string
}

variable "test_subnet_cidr" {
  description = "CIDR block of the test subnet (for security group rules)"
  type        = string
  default     = "100.64.0.0/24"
}
