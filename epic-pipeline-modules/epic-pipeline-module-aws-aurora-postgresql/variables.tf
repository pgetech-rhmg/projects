# Required variables (injected by EPIC)
variable "app_name" {
  description = "Application name used for naming the Aurora cluster and supporting resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, qa, prod)."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID for the Aurora security group."
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the DB subnet group. SAF requires private subnets only."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "subnet_ids must contain at least 2 subnets across distinct AZs."
  }
}

# Optional naming overrides
variable "custom_cluster_identifier" {
  description = "Full cluster identifier override."
  type        = string
  default     = null
  nullable    = true
}

variable "custom_db_cluster_parameter_group_name" {
  description = "Full DB cluster parameter group name override."
  type        = string
  default     = null
  nullable    = true
}

variable "custom_db_parameter_group_name" {
  description = "Full DB instance parameter group name override."
  type        = string
  default     = null
  nullable    = true
}

variable "custom_db_subnet_group_name" {
  description = "Full DB subnet group name override."
  type        = string
  default     = null
  nullable    = true
}

variable "custom_security_group_name" {
  description = "Full security group name override."
  type        = string
  default     = null
  nullable    = true
}

# Engine
variable "engine_version" {
  description = "Aurora PostgreSQL engine version."
  type        = string
  default     = "16.4"
}

variable "engine_mode" {
  description = "Engine mode. Provisioned (default) supports Serverless v2 via serverlessv2_scaling_configuration."
  type        = string
  default     = "provisioned"
}

variable "family" {
  description = "DB parameter group family (e.g. aurora-postgresql16)."
  type        = string
  default     = "aurora-postgresql16"
}

variable "database_name" {
  description = "Initial database name."
  type        = string
  default     = null
  nullable    = true
}

variable "port" {
  description = "Port the cluster listens on."
  type        = number
  default     = 5432
}

# Master credential
variable "master_username" {
  description = "Master DB username."
  type        = string
  default     = "epic_master"
}

variable "master_password" {
  description = "Master DB password. Required unless manage_master_user_password is true."
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "manage_master_user_password" {
  description = "If true, AWS manages the master credential in Secrets Manager. Cannot be combined with master_password."
  type        = bool
  default     = true
}

variable "master_user_secret_kms_key_id" {
  description = "KMS key for the AWS-managed master credential secret. Required for non-Internal/non-Public DataClassification."
  type        = string
  default     = null
  nullable    = true
}

# Encryption / SAF
variable "kms_key_id" {
  description = "KMS Key ARN for cluster + snapshot encryption. SAF requires CMK for Confidential / Restricted data."
  type        = string
  default     = null
  nullable    = true
}

variable "storage_encrypted" {
  description = "Whether storage encryption is enabled. SAF requires true."
  type        = bool
  default     = true
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM database authentication. Set false when fronted by RDS Proxy (proxy authenticates to Aurora via the master credential)."
  type        = bool
  default     = false
}

# Serverless v2
variable "serverlessv2_scaling_configuration" {
  description = "Serverless v2 scaling configuration. Empty map disables Serverless v2."
  type        = map(any)
  default     = {}
}

# Backups / maintenance
variable "backup_retention_period" {
  description = "Backup retention period in days. SAF requires >= 15."
  type        = number
  default     = 30

  validation {
    condition     = var.backup_retention_period >= 15
    error_message = "backup_retention_period must be at least 15 days per SAF."
  }
}

variable "preferred_backup_window" {
  description = "Daily time range for automated backups (UTC)."
  type        = string
  default     = null
  nullable    = true
}

variable "preferred_maintenance_window" {
  description = "Weekly maintenance window (UTC)."
  type        = string
  default     = null
  nullable    = true
}

variable "deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on delete."
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Final snapshot identifier."
  type        = string
  default     = null
  nullable    = true
}

variable "apply_immediately" {
  description = "Apply cluster modifications immediately."
  type        = bool
  default     = false
}

variable "allow_major_version_upgrade" {
  description = "Allow major version upgrades when changing engine_version."
  type        = bool
  default     = false
}

# Logging
variable "enabled_cloudwatch_logs_exports" {
  description = "Log types to export to CloudWatch (postgresql)."
  type        = list(string)
  default     = ["postgresql"]
}

# Cluster parameter group
variable "cluster_parameters" {
  description = "List of DB cluster parameters. SAF defaults enforce TLS via rds.force_ssl=1."
  type        = list(map(string))
  default = [
    {
      name  = "rds.force_ssl"
      value = "1"
    },
    {
      name  = "log_statement"
      value = "mod"
    }
  ]
}

# Instance parameter group
variable "instance_parameters" {
  description = "List of DB instance parameters."
  type        = list(map(string))
  default     = []
}

# Instances
variable "instance_count" {
  description = "Number of instances (writer + readers). Minimum 1."
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1
    error_message = "instance_count must be at least 1."
  }
}

variable "instance_class" {
  description = "Instance class (db.serverless for Serverless v2; db.r6g.large+ for provisioned)."
  type        = string
  default     = "db.serverless"
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights on each instance."
  type        = bool
  default     = true
}

variable "performance_insights_kms_key_id" {
  description = "KMS Key ARN for Performance Insights data."
  type        = string
  default     = null
  nullable    = true
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention in days (7 or 731)."
  type        = number
  default     = 7
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval (0, 1, 5, 10, 15, 30, 60 seconds)."
  type        = number
  default     = 60
}

variable "monitoring_role_arn" {
  description = "IAM role ARN used by Enhanced Monitoring. Required when monitoring_interval > 0."
  type        = string
  default     = null
  nullable    = true
}

variable "publicly_accessible" {
  description = "Whether instances are publicly accessible. SAF requires false."
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Whether minor engine upgrades are automatically applied during the maintenance window."
  type        = bool
  default     = true
}

# Security group
variable "ingress_security_group_ids" {
  description = "Security group IDs allowed to connect to the cluster on the configured port (e.g. lambda SG)."
  type        = list(string)
  default     = []
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the cluster on the configured port. Prefer SG-to-SG."
  type        = list(string)
  default     = []
}
