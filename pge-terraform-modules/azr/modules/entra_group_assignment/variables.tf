variable "subscription_id" {
  description = "Target subscription ID"
  type        = string
}

variable "read_only_groups" {
  description = "List of Azure AD group object IDs for Reader access"
  type        = list(string)
  default     = []
}

variable "read_write_groups" {
  description = "List of Azure AD group object IDs for Contributor access"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Reserved for future taggable resources and/or downstream metadata; currently not applied to any Azure resources created by this module"
  type        = map(string)
  default     = {}
}

