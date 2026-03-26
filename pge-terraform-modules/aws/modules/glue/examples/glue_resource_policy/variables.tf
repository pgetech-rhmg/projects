#Variables for provider
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "role_name" {
  description = "role name"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

#Variables for resource policy
variable "glue_enable_hybrid" {
  description = " Indicates that you are using both methods to grant cross-account. Valid values are TRUE and FALSE. Note the terraform will not perform drift detetction on this field as its not return on read."
  type        = string
}
