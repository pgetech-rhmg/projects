variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

# Standard PGE tags variables
variable "AppID" {
  description = "Application ID for resource tagging"
  type        = string
}

variable "Environment" {
  description = "Environment (Dev, Test, QA, Prod)"
  type        = string
}

variable "DataClassification" {
  description = "Data classification level"
  type        = string
}

variable "CRIS" {
  description = "CRIS number"
  type        = string
}

variable "Notify" {
  description = "Notification contact"
  type        = list(string)
}

variable "Owner" {
  description = "Resource owner"
  type        = list(string)
}

variable "Compliance" {
  description = "Compliance requirements"
  type        = list(string)
}

variable "Order" {
  description = "Order information"
  type        = number
}

variable "optional_tags" {
  description = "Optional additional tags"
  type        = map(string)
  default     = {}
}

variable "aws_role" {
  description = "AWS IAM role"
  type        = string
}

variable "kms_role" {
  description = "KMS role for encryption"
  type        = string
}

# KMS variables (optional)
variable "kms_name" {
  description = "Name for KMS key"
  type        = string
  default     = null
}

variable "kms_description" {
  description = "Description for KMS key"
  type        = string
  default     = null
}

# SSM Parameters for database credentials
variable "ssm_parameter_dms_username" {
  description = "SSM Parameter name containing database username"
  type        = string
}

variable "ssm_parameter_dms_password" {
  description = "SSM Parameter name containing database password"
  type        = string
}

# Source database endpoint variables
variable "source_endpoint_id" {
  description = "Source database endpoint identifier"
  type        = string
}

variable "source_endpoint_engine_name" {
  description = "Source database engine name (mysql, postgres, oracle, etc.)"
  type        = string
}

variable "source_endpoint_server_name" {
  description = "Source database server hostname"
  type        = string
}

variable "source_endpoint_database_name" {
  description = "Source database name"
  type        = string
}

variable "source_endpoint_port" {
  description = "Source database port"
  type        = string
}

variable "source_endpoint_ssl_mode" {
  description = "SSL mode for source database connection"
  type        = string
  default     = "require"
}

variable "source_certificate_arn" {
  description = "ARN of SSL certificate for source database"
  type        = string
  default     = null
}

variable "source_endpoint_service_access_role" {
  description = "ARN used by the service access IAM role for source endpoints (required for DynamoDB sources)"
  type        = string
  default     = null
}

variable "source_endpoint_extra_connection_attributes" {
  description = "Additional connection attributes for the source endpoint"
  type        = string
  default     = null
}

# S3 Target Endpoint Variables
variable "s3_target_endpoint_id" {
  description = "S3 target endpoint identifier for psps-tahs team"
  type        = string
}

variable "s3_target_bucket_name" {
  description = "Name of the S3 bucket where DMS will store migrated data"
  type        = string
}

variable "s3_target_bucket_arn" {
  description = "ARN of the target S3 bucket"
  type        = string
}

variable "s3_target_bucket_folder" {
  description = "Folder path within S3 bucket for organizing data (e.g., 'psps-tahs/migration-data')"
  type        = string
  default     = "psps-tahs/migration-data"
}

variable "s3_data_format" {
  description = "Data format for S3 files. Options: csv, parquet"
  type        = string
  default     = "csv"

  validation {
    condition     = contains(["csv", "parquet"], var.s3_data_format)
    error_message = "S3 data format must be either 'csv' or 'parquet'."
  }
}

variable "s3_compression_type" {
  description = "Compression type for S3 files. Options: NONE, GZIP"
  type        = string
  default     = "GZIP"

  validation {
    condition     = contains(["NONE", "GZIP"], var.s3_compression_type)
    error_message = "S3 compression type must be either 'NONE' or 'GZIP'."
  }
}

# Date partitioning variables
variable "enable_date_partitioning" {
  description = "Enable date-based partitioning in S3 for better data organization"
  type        = bool
  default     = true
}

variable "date_partition_sequence" {
  description = "Date partition format sequence"
  type        = string
  default     = "YYYYMMDD"

  validation {
    condition     = contains(["YYYYMMDD", "YYYYMMDDHH", "YYYYMM", "MMYYYYDD", "DDMMYYYY"], var.date_partition_sequence)
    error_message = "Date partition sequence must be one of: YYYYMMDD, YYYYMMDDHH, YYYYMM, MMYYYYDD, DDMMYYYY."
  }
}

# CSV specific settings
variable "csv_delimiter" {
  description = "Delimiter for CSV files"
  type        = string
  default     = ","
}

variable "csv_row_delimiter" {
  description = "Row delimiter for CSV files"
  type        = string
  default     = "\\n"
}

variable "include_op_for_full_load" {
  description = "Include operation columns for full load"
  type        = bool
  default     = false
}

variable "add_column_name" {
  description = "Add column names to CSV files"
  type        = bool
  default     = true
}

# Encryption settings
variable "s3_encryption_mode" {
  description = "S3 server-side encryption mode"
  type        = string
  default     = "SSE_S3"

  validation {
    condition     = contains(["SSE_S3", "SSE_KMS", "CSE_KMS"], var.s3_encryption_mode)
    error_message = "S3 encryption mode must be one of: SSE_S3, SSE_KMS, CSE_KMS."
  }
}

variable "s3_kms_key_id" {
  description = "KMS key ID for S3 server-side encryption (required if encryption_mode is SSE_KMS or CSE_KMS)"
  type        = string
  default     = null
}