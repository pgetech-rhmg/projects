#variables for aws_acm_certificate
variable "acm_private_key" {
  description = "acm_certificate_chain"
  type        = string
}

variable "acm_certificate_body" {
  description = "The certificate's PEM-formatted public key"
  type        = string
}

variable "acm_certificate_chain" {
  description = "The certificate's PEM-formatted chain"
  type        = string
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