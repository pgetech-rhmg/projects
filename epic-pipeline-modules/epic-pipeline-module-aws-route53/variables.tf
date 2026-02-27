variable "domain_name" {
  description = "Domain name for the ACM certificate and Route53 record"
  type        = string
  default     = null
  nullable    = true
}

variable "zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
  default     = null
  nullable    = true
}

variable "record_type" {
  description = "Type of records"
  type        = string
  default     = null
  nullable    = true
}

variable "target_domain_name" {
  description = "Target Domain name for the ACM certificate and Route53 record"
  type        = string
  default     = null
  nullable    = true
}

variable "target_zone_id" {
  description = "Target Route53 hosted zone ID"
  type        = string
  default     = null
  nullable    = true
}

variable "evaluate_target_health" {
  description = "Target Route53 hosted zone ID"
  type        = bool
  default     = false 
}

variable "domain_validation_options" {
  description = "Domains to create CNAME for"
  type        = list(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
  default     = []
}