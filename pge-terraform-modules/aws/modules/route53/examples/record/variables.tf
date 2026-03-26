variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

#variables for records
variable "zone_id" {
  description = "The ID of the hosted zone to contain this record."
  type        = string
}