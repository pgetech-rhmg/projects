# Variable for tags
variable "tags" {
  description = "A map of tags to apply to the created DMS endpoints."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# Variables for DMS source endpoint

variable "source_endpoint_id" {
  description = "Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.source_endpoint_id)) && length(var.source_endpoint_id) >= 1 && length(var.source_endpoint_id) <= 255 && !can(regex("--", var.source_endpoint_id))
    error_message = "Endpoint ID must contain 1-255 alphanumeric characters or hyphens, begin with a letter, and not contain consecutive hyphens."
  }
}

variable "source_endpoint_engine_name" {
  description = "Type of engine for the source endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb, mysql, opensearch, oracle, postgres, sqlserver, sybase."
  type        = string
}

variable "source_endpoint_kms_key_arn" {
  description = "ARN for the KMS key that will be used to encrypt the connection parameters for source endpoint."
  type        = string
  default     = null
}

variable "source_endpoint_database_name" {
  description = "Name of the source endpoint database."
  type        = string
  default     = null
}

variable "source_endpoint_extra_connection_attributes" {
  description = "Additional attributes associated with the source connection."
  type        = string
  default     = null
}

variable "source_endpoint_password" {
  description = "Password to be used to login to the source endpoint database."
  type        = string
  sensitive   = true
}

variable "source_endpoint_port" {
  description = "Port used by the source endpoint database."
  type        = string
}

variable "source_endpoint_server_name" {
  description = "Host name of the source server."
  type        = string
}

variable "source_endpoint_service_access_role" {
  description = "ARN used by the service access IAM role for dynamodb source endpoints."
  type        = string
  default     = null
}

variable "source_endpoint_ssl_mode" {
  description = "SSL mode to use for the source connection. Valid values are: none, require, verify-ca, verify-full. As per SAF, for each DMS endpoint where there is a port required, make sure the SSLMode is not 'None'."
  type        = string
  validation {
    condition = anytrue([
      var.source_endpoint_ssl_mode == "require",
      var.source_endpoint_ssl_mode == "verify-ca",
      var.source_endpoint_ssl_mode == "verify-full",
    ])
    error_message = "Error! As per SAF Rule, for each DMS endpoint where there is a port required, check to make sure the SSLMode is not 'None'."
  }
}

variable "source_endpoint_username" {
  description = "User name to be used to login to the source endpoint database."
  type        = string
}

variable "source_certificate_arn" {
  description = "ARN of the source SSL certificate"
  type        = string
  default     = null
}

# Variables for DMS S3 target endpoint

variable "endpoint_id" {
  description = "Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.endpoint_id)) && length(var.endpoint_id) >= 1 && length(var.endpoint_id) <= 255 && !can(regex("--", var.endpoint_id))
    error_message = "Endpoint ID must contain 1-255 alphanumeric characters or hyphens, begin with a letter, and not contain consecutive hyphens."
  }
}

variable "kms_key_arn" {
  description = "ARN for the KMS key that will be used to encrypt the connection parameters."
  type        = string
  default     = null
}

variable "service_access_role_arn" {
  description = "ARN of the IAM service access role used by DMS to access the S3 bucket. This role must have permissions to read/write to the specified S3 bucket."
  type        = string
}

# S3 Settings Variables
variable "s3_bucket_name" {
  description = "Name of the S3 bucket where DMS will store the migrated data."
  type        = string
}

variable "s3_bucket_folder" {
  description = "Folder path within the S3 bucket where DMS will store the migrated data. Optional."
  type        = string
  default     = null
}

variable "compression_type" {
  description = "Type of compression to apply to the data. Valid values: NONE, GZIP. Default is NONE."
  type        = string
  default     = "NONE"
  validation {
    condition     = contains(["NONE", "GZIP"], var.compression_type)
    error_message = "Compression type must be either NONE or GZIP."
  }
}

variable "csv_delimiter" {
  description = "Character used to separate columns in CSV files. Default is comma (,)."
  type        = string
  default     = ","
}

variable "csv_row_delimiter" {
  description = "Character used to separate rows in CSV files. Default is newline (\\n)."
  type        = string
  default     = "\\n"
}

variable "data_format" {
  description = "Output data format. Valid values: csv, parquet. Default is csv."
  type        = string
  default     = "csv"
  validation {
    condition     = contains(["csv", "parquet"], var.data_format)
    error_message = "Data format must be either csv or parquet."
  }
}

variable "date_partition_enabled" {
  description = "Whether to partition S3 bucket folders by transaction commit dates. Default is false."
  type        = bool
  default     = false
}

variable "date_partition_sequence" {
  description = "Identifies the sequence of the date format to use during folder partitioning. Valid values: YYYYMMDD, YYYYMMDDHH, YYYYMM, MMYYYYDD, DDMMYYYY. Default is YYYYMMDD."
  type        = string
  default     = "YYYYMMDD"
  validation {
    condition     = contains(["YYYYMMDD", "YYYYMMDDHH", "YYYYMM", "MMYYYYDD", "DDMMYYYY"], var.date_partition_sequence)
    error_message = "Date partition sequence must be one of: YYYYMMDD, YYYYMMDDHH, YYYYMM, MMYYYYDD, DDMMYYYY."
  }
}



variable "include_op_for_full_load" {
  description = "Whether to include operation columns for full load. Default is false."
  type        = bool
  default     = false
}

variable "cdc_inserts_only" {
  description = "Whether to write only INSERT operations to .csv or .parquet output files. Default is false."
  type        = bool
  default     = false
}



variable "parquet_timestamp_in_millisecond" {
  description = "Whether to output timestamp values in milliseconds for Parquet format. Default is false."
  type        = bool
  default     = false
}

variable "parquet_version" {
  description = "Version of Apache Parquet format. Valid values: parquet-1-0, parquet-2-0. Default is parquet-1-0."
  type        = string
  default     = "parquet-1-0"
  validation {
    condition     = contains(["parquet-1-0", "parquet-2-0"], var.parquet_version)
    error_message = "Parquet version must be either parquet-1-0 or parquet-2-0."
  }
}

variable "preserve_transactions" {
  description = "Whether to preserve transactions within the same file. Default is false."
  type        = bool
  default     = false
}

variable "server_side_encryption_kms_key_id" {
  description = "KMS key ID or ARN for server-side encryption of S3 objects. Optional."
  type        = string
  default     = null
}

variable "encryption_mode" {
  description = "Server-side encryption mode. Valid values: SSE_S3, SSE_KMS, CSE_KMS. Default is SSE_S3."
  type        = string
  default     = "SSE_S3"
  validation {
    condition     = contains(["SSE_S3", "SSE_KMS", "CSE_KMS"], var.encryption_mode)
    error_message = "Encryption mode must be one of: SSE_S3, SSE_KMS, CSE_KMS."
  }
}

variable "external_table_definition" {
  description = "JSON document that describes how AWS DMS should interpret the data. Optional."
  type        = string
  default     = null
}

variable "ignore_header_rows" {
  description = "Number of header rows to ignore when loading CSV files. Default is 0."
  type        = number
  default     = 0
}

variable "max_file_size" {
  description = "Maximum size of encoded, uncompressed .csv file in bytes. Default is 1048576 (1 MB)."
  type        = number
  default     = 1048576
}

variable "rfc_4180" {
  description = "Whether to use RFC 4180 standard for CSV files. Default is true."
  type        = bool
  default     = true
}













variable "add_column_name" {
  description = "Whether to add column name information to the .csv output files. Default is false."
  type        = bool
  default     = false
}