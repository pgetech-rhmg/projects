variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

##############################################################################
# Environment
##############################################################################

variable "environment_name" {
  type        = string
  description = "Name of the Container App Environment"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the Log Analytics workspace the environment logs to"
}

variable "infrastructure_subnet_id" {
  type        = string
  description = "Delegated subnet ID to VNet-inject the environment into. null leaves the environment on the Azure-managed network."
  default     = null
}

variable "internal_load_balancer_enabled" {
  type        = bool
  description = "Whether the environment uses an internal (private) load balancer. Requires infrastructure_subnet_id."
  default     = false
}

##############################################################################
# Container App
##############################################################################

variable "container_app_name" {
  type        = string
  description = "Name of the Container App"
}

variable "revision_mode" {
  type        = string
  description = "Revision mode"
  default     = "Single"

  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "revision_mode must be one of: Single, Multiple"
  }
}

variable "user_assigned_identity_id" {
  type        = string
  description = "Resource ID of the user-assigned identity used for registry pulls and Key Vault secret access"
}

variable "registry_server" {
  type        = string
  description = "Container registry login server (e.g. myregistry.azurecr.io). null omits the registry block."
  default     = null
}

variable "secrets" {
  type = list(object({
    name                = string
    key_vault_secret_id = string
  }))
  description = "Secrets sourced from Key Vault (versionless secret IDs), referenced by container env vars via secret_name."
  default     = []
}

##############################################################################
# Container template
##############################################################################

variable "container_name" {
  type        = string
  description = "Name of the container within the app"
  default     = "app"
}

variable "image" {
  type        = string
  description = "Fully-qualified container image (e.g. myregistry.azurecr.io/backend:tag)"
}

variable "cpu" {
  type        = number
  description = "CPU cores allocated to the container"
  default     = 0.5
}

variable "memory" {
  type        = string
  description = "Memory allocated to the container (e.g. \"1Gi\")"
  default     = "1Gi"
}

variable "min_replicas" {
  type        = number
  description = "Minimum replica count"
  default     = 1
}

variable "max_replicas" {
  type        = number
  description = "Maximum replica count"
  default     = 3
}

variable "env" {
  type = list(object({
    name        = string
    value       = optional(string)
    secret_name = optional(string)
  }))
  description = "Container environment variables. Set secret_name (matching a secrets[].name) for secret-backed vars; otherwise set value."
  default     = []
}

##############################################################################
# Ingress
##############################################################################

variable "ingress_external_enabled" {
  type        = bool
  description = "Whether ingress is reachable from outside the environment"
  default     = true
}

variable "target_port" {
  type        = number
  description = "Port the container listens on"
  default     = 8080
}

variable "ingress_transport" {
  type        = string
  description = "Ingress transport"
  default     = "auto"

  validation {
    condition     = contains(["auto", "http", "http2", "tcp"], var.ingress_transport)
    error_message = "ingress_transport must be one of: auto, http, http2, tcp"
  }
}
