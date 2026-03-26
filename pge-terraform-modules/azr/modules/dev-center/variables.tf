variable "partner_name" {
  description = "Name of the partner (for naming)"
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID of the partner resource group"
  type        = string
}

variable "location" {
  description = "Azure region for Dev Center"
  type        = string
}

variable "tags" {
  description = "Tags to apply to Dev Center resources"
  type        = map(string)
  default     = {}
}