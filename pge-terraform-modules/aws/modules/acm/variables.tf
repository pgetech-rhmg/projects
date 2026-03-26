variable "acm_domain_name" {
  description = "A domain name for which the certificate should be issued."
  type        = string
  validation {
    condition     = !can(regex("\\*", var.acm_domain_name))
    error_message = "Error! wildcards are not supported."
  }
}

variable "acm_r53update_validate" {
  description = "variable to set route53 addition with the certificate creation."
  type        = bool
  default     = true
}

variable "acm_subject_alternative_names" {
  description = "Set of domains that should be SANs in the issued certificate."
  type        = list(string)
  default     = null
}

variable "ttl" {
  description = "The TTL of the record."
  type        = number
  default     = 60
}

variable "allow_overwrite" {
  description = "Allow creation of this record in Terraform to overwrite an existing record."
  type        = bool
  default     = false
}

variable "certificate_transparency_logging_preference" {
  description = "Specifies whether certificate details should be added to a certificate transparency log."
  type        = string
  default     = "ENABLED"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

#variables for aws_acm_certificate_validation
variable "acm_validation_record_fqdns" {
  description = "List of FQDNs that implement the validation."
  type        = list(string)
  default     = null
}

variable "acm_validation_create_timeouts" {
  description = "How long to wait for a certificate to be issued."
  type        = string
  default     = "2880m"
}