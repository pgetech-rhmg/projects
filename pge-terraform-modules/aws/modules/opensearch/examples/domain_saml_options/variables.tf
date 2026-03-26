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

# variable "entity_id" {
#   type = string
# }

variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "domain_search" {
  description = "Boolean to enable/disable the domain search using data source query"
  type        = bool
  default     = true
}

variable "saml_options" {
  description = "SAML Options for the domain including metadata"
  type        = list(any)
  default     = []
}

variable "metadata_content_file" {
  description = "Metadata file content"
  type        = any
  default     = null
}
