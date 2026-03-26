# terraform.auto.tfvars
# Configuration example for psps-tahs team DMS with S3 target endpoint
# Update the values below with your specific settings; Terraform will auto-load this file.

AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]
Order              = 8115205 #Order must be between 7 and 9 digits


# Optional additional tags
optional_tags = {
  Project       = "PSPS-TAHS-Migration"
  Team          = "psps-tahs"
  CostCenter    = "CC-PSPS-001"
  BusinessOwner = "PSPS-TAHS-Manager"
}

# IAM Roles - Update with actual role ARNs
aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"
kms_role    = "TF_Developers"

# KMS Configuration (optional, uncomment if using encryption)
# kms_name        = "psps-tahs-dms-key"
# kms_description = "KMS key for PSPS-TAHS DMS encryption"

# SSM Parameter Store - Create these parameters in AWS Systems Manager
ssm_parameter_dms_username = "/dms/username"
ssm_parameter_dms_password = "/dms/password"

source_endpoint_id            = "test-source-manual-123"
source_endpoint_engine_name   = "sqlserver"
source_endpoint_server_name   = "m1rf-cyber.ctcxkxuqjgzd.us-west-2.rds.amazonaws.com"
source_endpoint_database_name = "m1rf-cyber"
source_endpoint_ssl_mode      = "require"
source_endpoint_port          = "1433"
source_certificate_arn        = null # certificate arn required if source_endpoint_ssl_mode if the value of source_endpoint_ssl_mode is "verify-ca" or "require"

# S3 Target Configuration - Update with your S3 details
s3_target_endpoint_id   = "psps-tahs-s3-target"
s3_target_bucket_name   = "pge-psps-tahs-dms-target-bucket"              # Update with actual bucket name
s3_target_bucket_arn    = "arn:aws:s3:::pge-psps-tahs-dms-target-bucket" # Update with actual bucket ARN
s3_target_bucket_folder = "psps-tahs/migration-data"                     # Customize folder structure
s3_data_format          = "csv"                                          # Options: csv, parquet
s3_compression_type     = "GZIP"                                         # Options: NONE, GZIP

# Date Partitioning Configuration - Helps organize data by date
enable_date_partitioning = true
date_partition_sequence  = "YYYYMMDD" # Options: YYYYMMDD, YYYYMMDDHH, YYYYMM, etc.

# CSV Configuration
csv_delimiter            = ","   # Comma-separated values
csv_row_delimiter        = "\\n" # Newline character
include_op_for_full_load = false # Include operation columns
add_column_name          = true  # Add column headers to CSV files

# S3 Encryption Configuration
s3_encryption_mode = "SSE_S3" # Options: SSE_S3, SSE_KMS, CSE_KMS
s3_kms_key_id      = null     # Required if using SSE_KMS or CSE_KMS

# Example values for different scenarios:

# For Parquet format with date partitioning:
# s3_data_format = "parquet"
# s3_compression_type = "GZIP"
# enable_date_partitioning = true
# date_partition_sequence = "YYYYMMDDHH"  # Hourly partitions

# For high-security data with KMS encryption:
# s3_encryption_mode = "SSE_KMS"
# s3_kms_key_id = "arn:aws:kms:region:account:key/key-id"

# For PostgreSQL source database:
# source_endpoint_engine_name = "postgres"
# source_endpoint_port = "5432"

# For Oracle source database:
# source_endpoint_engine_name = "oracle"
# source_endpoint_port = "1521"