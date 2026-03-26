variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ses_configuration_set_name" {
  description = "Name of the configuration set."
  type        = string
}