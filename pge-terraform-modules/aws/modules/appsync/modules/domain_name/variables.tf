#variables for domain_name
variable "domain_name" {
  description = "Name of the Domain name."
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the certificate. This can be an Certificate Manager (ACM) certificate or an Identity and Access Management (IAM) server certificate. The certifiacte must reside in us-east-1."
  type        = string
  validation {
    condition     = can(regex("^arn:aws:acm:\\w+(?:-\\w+)+:[[:digit:]]{12}:certificate/+(.*)$", var.certificate_arn))
    error_message = "Error! Enter a valid certificate arn."
  }
}

variable "description" {
  description = "The description of the domain_name."
  type        = string
  default     = null
}