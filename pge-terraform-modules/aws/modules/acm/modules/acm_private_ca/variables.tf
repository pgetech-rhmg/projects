#variables for aws_acm_certificate
variable "acm_domain_name" {
  description = "A domain name for which the certificate should be issued"
  type        = string
}

variable "acm_certificate_authority_arn" {
  description = "ARN of an ACM PCA"
  type        = string
}

variable "acm_subject_alternative_names" {
  description = "Set of domains that should be SANs in the issued certificate"
  type        = list(string)
  default     = null
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