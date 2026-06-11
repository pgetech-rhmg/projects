# Required variables (injected by EPIC)
variable "app_name" {
  description = "Application name used for naming the proxy."
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

variable "engine_family" {
  description = "Engine family for the proxy (POSTGRESQL, MYSQL, SQLSERVER)."
  type        = string

  validation {
    condition     = contains(["POSTGRESQL", "MYSQL", "SQLSERVER"], var.engine_family)
    error_message = "engine_family must be POSTGRESQL, MYSQL, or SQLSERVER."
  }
}

variable "secret_arns" {
  description = "List of Secrets Manager secret ARNs holding database credentials the proxy uses to connect to the target."
  type        = list(string)

  validation {
    condition     = length(var.secret_arns) >= 1
    error_message = "secret_arns must contain at least one Secrets Manager secret ARN."
  }
}

variable "role_arn" {
  description = "IAM role ARN the proxy uses to access secrets and CloudWatch."
  type        = string
}

variable "vpc_subnet_ids" {
  description = "List of VPC subnet IDs the proxy attaches to (private subnets)."
  type        = list(string)

  validation {
    condition     = length(var.vpc_subnet_ids) >= 2
    error_message = "vpc_subnet_ids must contain at least 2 subnets across distinct AZs."
  }
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs assigned to the proxy."
  type        = list(string)
}

# Optional inputs
variable "custom_proxy_name" {
  description = "Full proxy name override."
  type        = string
  default     = null
  nullable    = true
}

variable "require_tls" {
  description = "Require TLS on connections to the proxy. SAF requires true."
  type        = bool
  default     = true
}

variable "iam_auth" {
  description = "Whether IAM authentication is REQUIRED, DISABLED, or ENABLED for client connections to the proxy."
  type        = string
  default     = "REQUIRED"

  validation {
    condition     = contains(["REQUIRED", "DISABLED", "ENABLED"], var.iam_auth)
    error_message = "iam_auth must be REQUIRED, DISABLED, or ENABLED."
  }
}

variable "client_password_auth_type" {
  description = "Type of authentication the proxy uses for connections from clients (e.g. POSTGRES_SCRAM_SHA_256, POSTGRES_MD5)."
  type        = string
  default     = null
  nullable    = true
}

variable "auth_description" {
  description = "Description of the authentication entry."
  type        = string
  default     = null
  nullable    = true
}

variable "username" {
  description = "Username for the proxy auth block. When null, the proxy reads username from the secret."
  type        = string
  default     = null
  nullable    = true
}

variable "idle_client_timeout" {
  description = "Number of seconds a connection to the proxy can be inactive before being dropped."
  type        = number
  default     = 1800
}

variable "debug_logging" {
  description = "Enable enhanced debug logging. SAF strongly recommends keeping this disabled (auto-disables after 24h regardless)."
  type        = bool
  default     = false
}

# Target group (default)
variable "target_db_cluster_identifier" {
  description = "Aurora cluster identifier the proxy targets. Mutually exclusive with target_db_instance_identifier."
  type        = string
  default     = null
  nullable    = true
}

variable "target_db_instance_identifier" {
  description = "RDS DB instance identifier the proxy targets. Mutually exclusive with target_db_cluster_identifier."
  type        = string
  default     = null
  nullable    = true
}

variable "connection_pool_config" {
  description = <<EOT
Connection pool configuration for the default target group. Object shape:
{
  max_connections_percent      = optional(number, 100)
  max_idle_connections_percent = optional(number, 50)
  connection_borrow_timeout    = optional(number, 120)
  init_query                   = optional(string)
  session_pinning_filters      = optional(list(string), [])
}
EOT
  type = object({
    max_connections_percent      = optional(number, 100)
    max_idle_connections_percent = optional(number, 50)
    connection_borrow_timeout    = optional(number, 120)
    init_query                   = optional(string)
    session_pinning_filters      = optional(list(string), [])
  })
  default = {}
}
