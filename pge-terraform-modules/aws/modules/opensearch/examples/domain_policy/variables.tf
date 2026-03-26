variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "domain_search" {
  description = "Boolean to enable/disable the domain search using data source query"
  type        = bool
  default     = true
}
variable "aws_role" {
  description = "AWS role"
  type        = string
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}
variable "aws_region" {
  description = "AWS Region"
  type        = string
}