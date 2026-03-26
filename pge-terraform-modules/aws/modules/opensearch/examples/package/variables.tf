variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "aws_role" {
  description = "AWS role"
  type        = string
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}
variable "package_name" {
  description = "Package name"
  type        = string
}

variable "package_description" {
  description = "Package description"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket Name"
  type        = string
}

variable "s3_key" {
  description = "S3 key"
  type        = string
}

variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "domain_search" {
  description = "Boolean to enable/disable the domain search using data source query"
  type        = bool
  default     = true
}
