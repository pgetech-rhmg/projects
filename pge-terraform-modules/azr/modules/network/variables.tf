# Network Module
# Creates VNet, subnets, and NSGs

variable "partner_name" {
  description = "Partner name"
  type        = string
}

variable "partner_config" {
  description = "Partner configuration from YAML"
  type        = any
}

variable "resource_group_name" {
  description = "Resource group name for network resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID for resource creation"
  type        = string
}

# ========================================
# TAGGING - PGE FinOps and Compliance
# ========================================
# Standard PGE tags for cost management, compliance, and organizational purposes

variable "tags" {
  description = <<-EOT
    PGE FinOps compliant tags to apply to all resources. Required tags:
    - AppID: Application identifier (e.g., "APP-12345")
    - Environment: Dev, Test, QA, or Prod
    - DataClassification: Public, Internal, Confidential, Restricted, Privileged, Confidential-BCSI, or Restricted-BCSI
    - CRIS: Risk level - High, Medium, or Low
    - Notify: Email address(es) for notifications
    - Owner: LANID(s) of resource owner(s)
    - Compliance: SOX, HIPAA, CCPA, BCSI, or None
    - Order: Purchase order number (7-9 digits)
  EOT
  type        = map(string)
  default = {
    AppId              = "123456"
    Env                = "Dev"
    Owner              = "owner@pge.com"
    Compliance         = "SOX"
    Notify             = "notify@pge.com"
    DataClassification = "internal"
    CRIS               = "1"
    CostCenter         = "IT-Operations"
    order              = "123456"
    ChargeBackCode     = "IT"
    ResourceType       = "Network"
    ManagedBy          = "Terraform"
  }

  validation {
    condition     = alltrue([for k, v in var.tags : length(k) > 0 && length(v) > 0])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

# ========================================
# CALCULATED SUBNETS FROM INFOBLOX
# ========================================
# These override YAML-defined subnets when provided

variable "calculated_vnet_address_space" {
  description = "VNet address space from Infoblox CIDR allocation (e.g., 10.94.138.0/22)"
  type        = string
  default     = null
}

variable "calculated_subnets" {
  description = "Pre-calculated subnets with delegations and service endpoints"
  type        = any # Flexible type to handle varying subnet configurations
  default     = null
}

# ========================================
# HUB FIREWALL CONFIGURATION
# ========================================
# Hub-Palo firewall IP for transit routing

variable "hub_firewall_ip" {
  description = "Hub-Palo firewall internal IP for default route (0.0.0.0/0)"
  type        = string
  default     = "10.94.252.100"
}
