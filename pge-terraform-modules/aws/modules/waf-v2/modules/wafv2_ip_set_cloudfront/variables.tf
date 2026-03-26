# Variables for resource 'aws_wafv2_ip_set'

variable "wafv2_ip_set_name" {
  description = "A friendly name of the IP set."
  type        = string
}

variable "wafv2_ip_set_description" {
  description = "A friendly description of the IP set."
  type        = string
  default     = null
}

variable "wafv2_ip_set_ip_address_version" {
  description = "Specify IPV4 or IPV6. Valid values are IPV4 or IPV6."
  type        = string
  validation {
    condition     = contains(["IPV4", "IPV6"], var.wafv2_ip_set_ip_address_version)
    error_message = "Valid values for scope are (IPV4,IPV6)."
  }
}

variable "wafv2_ip_set_addresses" {
  description = "Contains an array of strings that specify one or more IP addresses or blocks of IP addresses in Classless Inter-Domain Routing (CIDR) notation. AWS WAF supports all address ranges for IP versions IPv4 and IPv6."
  type        = list(string)
}

# Variables for Tags

variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

