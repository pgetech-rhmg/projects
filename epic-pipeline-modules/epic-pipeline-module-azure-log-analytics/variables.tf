variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
}

variable "workspace_name" {
  type        = string
  description = "Name of the Log Analytics workspace"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

variable "sku" {
  type        = string
  description = "Log Analytics pricing SKU"
  default     = "PerGB2018"

  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.sku)
    error_message = "sku must be a valid Log Analytics SKU (e.g. PerGB2018)."
  }
}

variable "retention_in_days" {
  type        = number
  description = "Workspace data retention in days (30-730)"
  default     = 30

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "retention_in_days must be between 30 and 730."
  }
}

variable "internet_ingestion_enabled" {
  type        = bool
  description = "Whether logs may be ingested from the public internet"
  default     = true
}

variable "internet_query_enabled" {
  type        = bool
  description = "Whether the workspace may be queried from the public internet"
  default     = true
}
