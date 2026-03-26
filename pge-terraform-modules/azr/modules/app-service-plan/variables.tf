variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "service_plan_name" {
  type        = string
  description = "Name of the App Service Plan"
}

variable "ase_id" {
  type        = string
  description = "ID of the App Service Environment (optional - omit for public plan)"
  default     = ""
}

variable "os_type" {
  type        = string
  description = "Operating system type (Windows or Linux)"
  default     = "Linux"

  validation {
    condition     = contains(["Windows", "Linux"], var.os_type)
    error_message = "os_type must be 'Windows' or 'Linux'."
  }
}

variable "sku_name" {
  type        = string
  description = "SKU name (e.g., P1v2, S2, B2)"
  default     = "P1v2"
}

variable "worker_count" {
  type        = number
  description = "Number of worker instances"
  default     = 2

  validation {
    condition     = var.worker_count >= 1 && var.worker_count <= 100
    error_message = "worker_count must be between 1 and 100."
  }
}

variable "per_site_scaling_enabled" {
  type        = bool
  description = "Enable per-site scaling"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
