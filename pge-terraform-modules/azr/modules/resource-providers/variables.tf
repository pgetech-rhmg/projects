# Resource Providers Module
# Auto-registers required Azure resource providers

variable "subscription_id" {
  description = "Subscription ID for provider registration"
  type        = string
}

variable "resource_providers" {
  description = "List of Azure resource providers to register"
  type        = list(string)
  default = [
    "Microsoft.Compute",
    "Microsoft.Network",
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.ManagedIdentity",
    "Microsoft.OperationalInsights",
    "Microsoft.Security",
    "Microsoft.Authorization",
    "Microsoft.Web",                  # App Service, ASE
    "Microsoft.Cache",                # Redis Cache
    "Microsoft.Sql",                  # SQL Database
    "Microsoft.DevOpsInfrastructure", # Azure Managed DevOps Pools
    "Microsoft.DevCenter"
  ]
}

# Dev note, not sure what this is doing, but leaving it here for now in case we need to add custom DNS servers to the
# VNet configuration in the future. It doesn't do anything in this module, but it can be used as an output for other
# modules that might need it.
variable "custom_dns_servers" {
  description = "Custom DNS servers for VNet configuration"
  type        = list(string)
  default     = []
}
