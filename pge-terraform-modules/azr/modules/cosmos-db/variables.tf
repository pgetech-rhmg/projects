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

variable "capacity_mode" {
  type        = string
  description = "Capacity mode for Cosmos DB"
  default     = "serverless"

  validation {
    condition     = contains(["serverless", "provisioned"], var.capacity_mode)
    error_message = "Capacity mode must be 'serverless' or 'provisioned'."
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

variable "consistency_level" {
  type        = string
  description = "Consistency level for Cosmos DB"
  default     = "BoundedStaleness"

  validation {
    condition = contains([
      "BoundedStaleness", "Eventual", "Session", "Strong", "ConsistentPrefix"
    ], var.consistency_level)
    error_message = "Consistency level must be one of: BoundedStaleness, Eventual, Session, Strong, ConsistentPrefix."
  }
}

variable "backup_interval_in_minutes" {
  type        = number
  description = "Backup interval in minutes (60-1440 for Periodic, ignored for Continuous)"
  default     = 1440

  validation {
    condition     = var.backup_interval_in_minutes >= 60 && var.backup_interval_in_minutes <= 1440
    error_message = "Backup interval must be between 60 and 1440 minutes."
  }
}

variable "backup_retention_interval_in_hours" {
  type        = number
  description = "Backup retention interval in hours (48-720 hours = 2-30 days)"
  default     = 48 # 2 days

  validation {
    condition     = var.backup_retention_interval_in_hours >= 48 && var.backup_retention_interval_in_hours <= 720
    error_message = "Backup retention must be between 48 and 720 hours (2-30 days)."
  }
}

variable "backup_storage_redundancy" {
  type        = string
  description = "Backup storage redundancy"
  default     = "Local"

  validation {
    condition     = contains(["Geo", "Local", "Zone"], var.backup_storage_redundancy)
    error_message = "Backup storage redundancy must be 'Geo', 'Local', or 'Zone'."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

variable "max_throughput" {
  type        = number
  description = "Maximum throughput for autoscale (only applies to provisioned mode)"
  default     = 4000

  validation {
    condition     = var.max_throughput >= 400 && var.max_throughput <= 1000000
    error_message = "Max throughput must be between 400 and 1,000,000 RU/s."
  }
}

variable "key_vault_key_id" {
  type        = string
  description = "Optional: Key Vault key ID for customer-managed keys (CMK) encryption. If not provided, the Cosmos DB account will use Microsoft-managed keys."
  default     = ""

}