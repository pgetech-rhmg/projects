# ============================================================================
# Infoblox CIDR Allocation Module - Variables
# ============================================================================
# Azure Deployment Script based CIDR allocation from private Infoblox Function App
# ============================================================================

variable "partner_name" {
  description = "Partner name for resource naming"
  type        = string
}

variable "subscription_id" {
  description = "Target subscription ID for the VNet (passed to Infoblox for tracking)"
  type        = string
}

variable "region" {
  description = "Azure region ID for Infoblox allocation (e.g., 'west-us-2', 'east-us')"
  type        = string
}

variable "network_size" {
  description = "VNet size: tiny (/25), small (/24), medium (/23), large (/22), giant (/21)"
  type        = string
  default     = "large"

  validation {
    condition     = contains(["tiny", "small", "medium", "large", "giant"], var.network_size)
    error_message = "network_size must be one of: tiny, small, medium, large, giant"
  }
}

variable "location" {
  description = "Azure region for Deployment Script (ACI) deployment"
  type        = string
  default     = "westus2"
}

# ============================================================================
# Shared Infrastructure Configuration
# ============================================================================

variable "shared_subscription_id" {
  description = "Subscription ID where the shared VNet and Function App reside"
  type        = string
}

variable "shared_resource_group" {
  description = "Resource group where Deployment Script and storage will be created"
  type        = string
}

variable "shared_vnet_resource_group" {
  description = "Resource group containing the VNet (may differ from shared_resource_group)"
  type        = string
  default     = "" # If empty, uses shared_resource_group
}

variable "shared_vnet_name" {
  description = "Name of the shared VNet"
  type        = string
}

variable "aci_subnet_name" {
  description = "Subnet name for Deployment Script (ACI) deployment (must have Microsoft.ContainerInstance/containerGroups delegation)"
  type        = string
}

# ============================================================================
# Function App Configuration
# ============================================================================

variable "function_app_hostname" {
  description = "Hostname of the Infoblox Function App (without https://)"
  type        = string
}

variable "function_key" {
  description = "Function App host key for authentication"
  type        = string
  sensitive   = true
}
# ============================================================================
# Common Tags
# ============================================================================

variable "common_tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}