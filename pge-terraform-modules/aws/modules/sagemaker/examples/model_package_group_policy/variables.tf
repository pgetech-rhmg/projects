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

# Variables for Model Package Group Policy

variable "model_package_group_name" {
  description = "The name of the model package group."
  type        = string
}