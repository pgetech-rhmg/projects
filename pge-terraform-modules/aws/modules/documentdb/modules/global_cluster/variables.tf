#variables for global cluster
variable "global_cluster_identifier" {
  description = "The global cluster identifier."
  type        = string
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation."
  type        = string
  default     = ""
}

variable "deletion_protection" {
  description = "If the Global Cluster should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false."
  type        = bool
  default     = false
}

variable "engine" {
  description = "Name of the database engine to be used for this DB cluster. Terraform will only perform drift detection if a configuration value is provided. Current Valid values: docdb. Defaults to docdb. Conflicts with source_db_cluster_identifier."
  type        = string
  default     = "docdb"
  validation {
    condition     = contains(["docdb"], var.engine)
    error_message = "Error! engine  value must be 'docdb'!"
  }
}

variable "engine_version" {
  description = "Engine version of the global database. Upgrading the engine version will result in all cluster members being immediately updated and will."
  type        = string
  default     = "4.0.0"
  validation {
    condition     = contains(["4.0.0", "3.6.0"], var.engine_version)
    error_message = "Error! engine version value must be '4.0.0', '3.6.0'!"
  }
}

variable "timeouts" {
  description = "The cluster timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours."
  type        = map(string)
  default     = {}
}

variable "source_db_cluster_identifier" {
  description = "Amazon Resource Name (ARN) to use as the primary DB Cluster of the Global Cluster on creation. Terraform cannot perform drift detection of this value."
  type        = string
  default     = null
}