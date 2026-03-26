variable "domain_name" {
  description = "Name of the fleet."
  type        = string
}

variable "saml_options" {
  description = "SAML Options for domain"
  type        = list(any)
}

variable "metadata_content_file" {
  description = "metadata_content_file."
  type        = any
  default     = null
}