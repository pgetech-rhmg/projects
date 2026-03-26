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

#variables for code_repository
variable "name" {
  description = "The name of the lifecycle configuration (must be unique)."
  type        = string
}

variable "on_create" {
  description = "A shell script (base64-encoded) that runs only once when the SageMaker Notebook Instance is created."
  type        = string
}

variable "on_start" {
  description = "A shell script (base64-encoded) that runs every time the SageMaker Notebook Instance is started including the time it's created."
  type        = string
}