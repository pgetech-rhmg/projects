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
    "Microsoft.DevCenter"             # Azure Dev Center
  ]
}
