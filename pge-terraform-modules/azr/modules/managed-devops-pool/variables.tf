# Azure Managed DevOps Pool Module Variables

variable "pool_name" {
  description = "Name of the managed DevOps pool"
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID of the resource group where the pool will be created"
  type        = string
}

variable "location" {
  description = "Azure region for the managed pool"
  type        = string
}

variable "ado_org_url" {
  description = "Azure DevOps organization URL (e.g., https://dev.azure.com/myorg)"
  type        = string
}

variable "ado_project_names" {
  description = "List of Azure DevOps project names that can use this pool"
  type        = list(string)
}

variable "max_parallel_jobs" {
  description = "Maximum number of parallel jobs per project"
  type        = number
  default     = 1
}

variable "agent_sku" {
  description = "Azure VM SKU for agents (e.g., Standard_D4as_v5, Standard_D2s_v5, Standard_F2s_v2)"
  type        = string
  default     = "Standard_D4as_v5" # D-series AMD v5 - working
}

variable "agent_image" {
  description = "Well-known image name for agents (e.g., ubuntu-24.04/latest, windows-2022/latest)"
  type        = string
  default     = "ubuntu-24.04/latest"
}

variable "max_agents" {
  description = "Maximum number of agents in the pool"
  type        = number
  default     = 10
}

variable "subnet_id" {
  description = "Subnet ID for agent network connectivity (optional)"
  type        = string
  default     = null
}

variable "managed_identity_id" {
  description = "Resource ID of the UserAssigned managed identity (MI2) for the pool"
  type        = string
  validation {
    condition     = can(regex("/providers/Microsoft.ManagedIdentity/userAssignedIdentities/", var.managed_identity_id))
    error_message = "managed_identity_id must be a valid managed identity resource ID."
  }
}

variable "dev_center_project_id" {
  description = "Resource ID of the Dev Center project for pool governance (REQUIRED by API)"
  type        = string
  validation {
    condition     = can(regex("/providers/Microsoft.DevCenter/projects/", var.dev_center_project_id))
    error_message = "dev_center_project_id must be a valid Dev Center project resource ID."
  }
}

variable "resource_providers_registered" {
  description = "Dependency placeholder to ensure resource providers are registered"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the managed pool"
  type        = map(string)
  default     = {}
}