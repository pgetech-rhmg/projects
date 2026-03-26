# Observability Module
# Creates Log Analytics Workspace

variable "partner_name" {
  description = "Partner name"
  type        = string
}

variable "partner_config" {
  description = "Partner configuration from YAML"
  type        = any
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
