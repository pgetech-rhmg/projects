variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
}

variable "name" {
  type        = string
  description = "Name of the Application Insights resource"
}

variable "workspace_id" {
  type        = string
  description = "Resource ID of the Log Analytics workspace to back this component (workspace-based App Insights)."
}

variable "application_type" {
  type        = string
  description = "Application type reported to Application Insights"
  default     = "web"

  validation {
    condition     = contains(["web", "other", "java", "Node.JS", "general"], var.application_type)
    error_message = "application_type must be one of: web, other, java, Node.JS, general"
  }
}

variable "retention_in_days" {
  type        = number
  description = "Data retention in days"
  default     = 90
}

variable "sampling_percentage" {
  type        = number
  description = "Percentage of telemetry sampled (100 = no sampling)"
  default     = 100
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
