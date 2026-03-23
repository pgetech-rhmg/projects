###############################################################################
# Organization & Account
###############################################################################

variable "principal_orgid" {
  description = "Organization id."
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account used for this resource."
  type        = string
}

variable "aws_region" {
  description = "Deployment region."
  type        = string
}


###############################################################################
# Application
###############################################################################

variable "app_name" {
  description = "Application name used for naming resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, qa, prod)."
  type        = string
}

variable "health_check_path" {
  type        = string
  description = "API health check path."
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "app_executable" {
  description = "Name of the .NET executable."
  type        = string
}


###############################################################################
# Tagging & Compliance
###############################################################################

variable "appid" {
  description = "Identify the application this asset belongs to by its AMPS APP ID."
  type        = number
}

variable "notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance."

  validation {
    condition = alltrue([
      for aliases in var.notify : can(regex("^\\w+([\\.!-/:[-`{-~]?\\w+)*@([\\.-]?\\w+)*(\\.\\w{2,3})+$", aliases))
    ])
    error_message = "Invalid Email Address for Notify tag."
  }
}

variable "owner" {
  type        = list(string)
  description = "Three owners of the system (LANID1, LANID2, LANID3)."

  validation {
    condition     = length(var.owner) == 3
    error_message = "List three owners of the system."
  }
}

variable "order" {
  type        = number
  description = "Cost center order number."

  validation {
    condition     = var.order >= 1000000 && var.order <= 999999999
    error_message = "Order must be a number between 7 and 9 digits."
  }
}

variable "dataclassification" {
  type        = string
  description = "Data classification level."
  default     = "Internal"

  validation {
    condition     = contains(["Public", "Internal", "Confidential", "Restricted", "Privileged", "Confidential-BCSI", "Restricted-BCSI"], var.dataclassification)
    error_message = "Valid values: Public, Internal, Confidential, Restricted, Privileged, Confidential-BCSI, Restricted-BCSI."
  }
}

variable "compliance" {
  type        = list(string)
  description = "Compliance requirements."
  default     = ["None"]

  validation {
    condition = alltrue([
      for alias in var.compliance : contains(["SOX", "HIPAA", "CCPA", "BCSI", "None"], alias)
    ])
    error_message = "Valid values: SOX, HIPAA, CCPA, BCSI, None."
  }
}

variable "cris" {
  type        = string
  description = "Cyber Risk Impact Score."
  default     = "Low"

  validation {
    condition     = contains(["High", "Medium", "Low"], var.cris)
    error_message = "Valid values: High, Medium, Low."
  }
}


###############################################################################
# Networking
###############################################################################

variable "network" {
  type = object({
    vpc_id              = string
    subnet_ids          = list(string)
    main_route_table_id = string
  })
}

variable "api_domain_name" {
  description = "Domain name for the API (ALB + Route53)."
  type        = string
}

variable "private_hosted_zone_id" {
  description = "Route53 private hosted zone ID."
  type        = string
}

variable "public_hosted_zone_id" {
  description = "Route53 public hosted zone ID."
  type        = string
}


###############################################################################
# Secrets
###############################################################################

variable "secrets" {
  type        = map(string)
  description = "Secret string key-value pairs."
}

variable "secrets_description" {
  type        = string
  description = "Secret description."
}


###############################################################################
# Database (Aurora PostgreSQL Serverless v2)
###############################################################################

variable "db_name" {
  description = "Database name."
  type        = string
  default     = "epicdb"
}

variable "db_master_username" {
  description = "Master username for Aurora."
  type        = string
  default     = "epic"
}

variable "db_min_capacity" {
  description = "Aurora Serverless v2 minimum ACUs."
  type        = number
  default     = 0.5
}

variable "db_max_capacity" {
  description = "Aurora Serverless v2 maximum ACUs."
  type        = number
  default     = 2
}


###############################################################################
# S3
###############################################################################

variable "force_s3_destroy" {
  description = "Allow Terraform to delete S3 bucket with objects."
  type        = bool
  default     = false
}

variable "custom_bucket_name" {
  description = "Custom S3 bucket name."
  type        = string
  default     = null
  nullable    = true
}

variable "object_ownership" {
  description = "S3 object ownership setting."
  type        = string
  default     = "BucketOwnerEnforced"
}

variable "enable_public_access_block" {
  description = "Block all public access at the bucket level."
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning."
  type        = bool
  default     = false
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm (AES256 or aws:kms)."
  type        = string
  default     = "AES256"
}

variable "kms_key_arn" {
  description = "KMS Key ARN for SSE-KMS."
  type        = string
  default     = null
}

variable "enable_access_logging" {
  description = "Enable S3 server access logging."
  type        = bool
  default     = false
}

variable "access_log_bucket" {
  description = "Target bucket for access logs."
  type        = string
  default     = null
}

variable "access_log_prefix" {
  description = "Prefix for access logs."
  type        = string
  default     = null
}

variable "lifecycle_rules" {
  description = "S3 lifecycle rules."
  type        = any
  default     = []
}

variable "bucket_policy_json" {
  description = "Optional raw JSON bucket policy."
  type        = string
  default     = null
  nullable    = true
}
