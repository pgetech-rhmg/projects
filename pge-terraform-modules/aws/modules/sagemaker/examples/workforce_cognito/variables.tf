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

#variables for workforce
variable "name" {
  description = "The name of the Workforce (must be unique)."
  type        = string
}

variable "cidrs" {
  description = "A list of IP address ranges Used to create an allow list of IP addresses for a private workforce. By default, a workforce isn't restricted to specific IP addresses."
  type        = list(any)
}