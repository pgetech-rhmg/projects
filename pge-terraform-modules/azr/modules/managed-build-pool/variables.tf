variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region location"
  type        = string
}

variable "partner_name" {
  description = "Partner name (used in resource naming)"
  type        = string
}

variable "partner_index" {
  description = "Partner index for CIDR block (0-254)"
  type        = number
  validation {
    condition     = var.partner_index >= 0 && var.partner_index <= 254
    error_message = "Partner index must be between 0 and 254."
  }
}

variable "build_agent_sku" {
  description = "Azure VM SKU for build agents"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "build_agent_instances" {
  description = "Initial number of build agents (from ado_pool_size in YAML)"
  type        = number
  default     = 3
  validation {
    condition     = var.build_agent_instances >= 1 && var.build_agent_instances <= 100
    error_message = "Build agent instances must be between 1 and 100."
  }
}

variable "build_pool_max_agents" {
  description = "Maximum number of build agents for auto-scaling"
  type        = number
  default     = 5
  validation {
    condition     = var.build_pool_max_agents >= 1 && var.build_pool_max_agents <= 500
    error_message = "Max agents must be between 1 and 500."
  }
}

variable "build_pool_desired_idle" {
  description = "Desired number of idle agents to maintain"
  type        = number
  default     = 1
  validation {
    condition     = var.build_pool_desired_idle >= 0 && var.build_pool_desired_idle <= 10
    error_message = "Desired idle agents must be between 0 and 10."
  }
}

variable "build_agent_image" {
  description = "Base operating system image for build agents"
  type        = string
  default     = "Ubuntu-22.04"
  validation {
    condition     = contains(["Ubuntu-22.04", "Windows-2022"], var.build_agent_image)
    error_message = "Build agent image must be either Ubuntu-22.04 or Windows-2022."
  }
}

variable "ado_url" {
  description = "Azure DevOps organization URL"
  type        = string
}

variable "ado_pat_token" {
  description = "Azure DevOps personal access token for agent registration"
  type        = string
  sensitive   = true
}

variable "managed_identity_id" {
  description = "Resource ID of the managed identity for build agents"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network (CIDR block) - should come from YAML network configuration"
  type        = list(string)
  default     = ["10.100.0.0/16"] # Fallback default, should be overridden by YAML
  validation {
    condition     = length(var.vnet_address_space) > 0
    error_message = "VNet address space must contain at least one CIDR block."
  }
}

variable "subnet_address_prefix" {
  description = "Address prefix for the build agents subnet (CIDR block) - should come from YAML network configuration"
  type        = string
  default     = "10.100.2.0/24" # Fallback default, should be overridden by YAML
}

variable "security_rules" {
  description = "List of additional security rules for outbound access (e.g., for custom ports)"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [
    {
      name                       = "AllowHTTPS"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
