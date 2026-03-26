# Variables for Redshift Serverless

# Namespace Variables
variable "namespace_name" {
  description = "The name of the namespace. Must be a lower case string."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.namespace_name))
    error_message = "Namespace name must be lowercase alphanumeric with hyphens only."
  }
}

variable "admin_username" {
  description = "The username of the administrator for the first database created in the namespace."
  type        = string
  default     = null
  validation {
    condition     = var.admin_username == null || !can(regex("awsuser", var.admin_username))
    error_message = "Default user name 'awsuser' is not allowed."
  }
}

variable "admin_user_password" {
  description = "The password of the administrator for the first database created in the namespace."
  type        = string
  default     = null
  sensitive   = true
  validation {
    condition     = var.admin_user_password == null || (length(var.admin_user_password) >= 16 && !can(regex("[@/\"]", var.admin_user_password)))
    error_message = "Admin password must be at least sixteen characters long and cannot contain a / (slash), \" (double quote) or @ (at symbol)."
  }
}

variable "db_name" {
  description = "The name of the first database created in the namespace."
  type        = string
  default     = null
}

variable "default_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM role to set as a default in the namespace."
  type        = string
  default     = null
}

variable "iam_role_arns" {
  description = "A list of IAM roles to associate with the namespace."
  type        = list(string)
  default     = []
}

variable "kms_key_id" {
  description = "The ARN of the Amazon Web Services Key Management Service key used to encrypt your data."
  type        = string
  default     = null
}

variable "log_exports" {
  description = "The types of logs the namespace can export. Available export types are userlog, connectionlog, and useractivitylog."
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for log_type in var.log_exports : contains(["userlog", "connectionlog", "useractivitylog"], log_type)
    ])
    error_message = "Log exports can only be userlog, connectionlog, or useractivitylog."
  }
}

variable "manage_admin_password" {
  description = "Whether to use AWS SecretManager to manage namespace admin credentials. NOTE: Currently not supported - must be false. Use admin_user_password instead."
  type        = bool
  default     = false
  validation {
    condition     = var.manage_admin_password == false
    error_message = "manage_admin_password must be false. AWS Secrets Manager password management is not currently supported. Please provide admin_user_password."
  }
}

# Workgroup Variables
variable "workgroup_name" {
  description = "The name of the workgroup. Must be a lower case string."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.workgroup_name))
    error_message = "Workgroup name must be lowercase alphanumeric with hyphens only."
  }
}

variable "base_capacity" {
  description = "The base data warehouse capacity of the workgroup in Redshift Processing Units (RPUs)."
  type        = number
  default     = 128
  validation {
    condition     = contains([32, 40, 48, 56, 64, 72, 80, 88, 96, 104, 112, 120, 128, 136, 144, 152, 160, 168, 176, 184, 192, 200, 208, 216, 224, 232, 240, 248, 256, 264, 272, 280, 288, 296, 304, 312, 320, 328, 336, 344, 352, 360, 368, 376, 384, 392, 400, 408, 416, 424, 432, 440, 448, 456, 464, 472, 480, 488, 496, 504, 512], var.base_capacity)
    error_message = "Base capacity must be in increments of 8 RPUs between 32 and 512."
  }
}

variable "max_capacity" {
  description = "The maximum data warehouse capacity Amazon Redshift Serverless uses to serve queries, specified in Redshift Processing Units (RPUs)."
  type        = number
  default     = null
}

variable "publicly_accessible" {
  description = "A value that specifies whether the workgroup can be accessed from a public network."
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "An array of VPC subnet IDs to associate with the workgroup."
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) >= 3
    error_message = "At least 3 subnet IDs are required for high availability."
  }
}

variable "security_group_ids" {
  description = "An array of security group IDs to associate with the workgroup."
  type        = list(string)
}

variable "enhanced_vpc_routing" {
  description = "The value that specifies whether to turn on enhanced virtual private cloud (VPC) routing."
  type        = bool
  default     = false
}

variable "port" {
  description = "The port number on which the cluster accepts incoming connections."
  type        = number
  default     = 5439
}

variable "config_parameters" {
  description = "An array of parameters to set for more control over a serverless database."
  type = list(object({
    parameter_key   = string
    parameter_value = string
  }))
  default = []
}

# Tags
variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
}
