#Variables for provider

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume."
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory."
  type        = string
}

# Variables for Glue Classifier

variable "name" {
  description = "The name of the classifier."
  type        = string
}

variable "csv_classifier" {
  description = "A classifier for Csv content."
  type        = list(any)
}
