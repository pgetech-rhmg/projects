variable "name" {
  type        = string
  description = "Name of the Cosmos DB account"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "api_type" {
  type        = string
  description = "API type for Cosmos DB"
  default     = "sql"

  validation {
    condition     = contains(["sql", "mongodb", "cassandra", "gremlin", "table"], var.api_type)
    error_message = "API type must be one of: sql, mongodb, cassandra, gremlin, table."
  }
}

variable "database_name" {
  type        = string
  description = "Name of the database to create"
}

variable "container_name" {
  type        = string
  description = "Name of the container to create"
}

variable "partition_key" {
  type        = string
  description = "Partition key path for the container"
  default     = "/partitionKey"

  validation {
    condition     = can(regex("^/[a-zA-Z0-9_-]+", var.partition_key))
    error_message = "Partition key must start with '/' and contain only alphanumeric characters, underscores, and hyphens."
  }
}
variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
variable "capacity_mode" {
  type        = string
  description = "Capacity mode for Cosmos DB"
  default     = "serverless"

  validation {
    condition     = contains(["serverless", "provisioned"], var.capacity_mode)
    error_message = "Capacity mode must be 'serverless' or 'provisioned'."
  }

}

# variable "key_vault_key_id" {
#   type        = string
#   description = "Optional: Key Vault key ID for customer-managed keys (CMK) encryption. If not provided, the Cosmos DB account will use Microsoft-managed keys."
#   default     = ""

# }
