run "dms-s3-target-endpoint" {
  command = apply

  module {
    source = "./examples/dms-s3-target-endpoint"
  }
}

variables {
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags = {
    Project       = "PSPS-TAHS-Migration"
    Team          = "psps-tahs"
    CostCenter    = "CC-PSPS-001"
    BusinessOwner = "PSPS-TAHS-Manager"
  }
  aws_region                    = "us-west-2"
  account_num                   = "750713712981"
  aws_role                      = "CloudAdmin"
  kms_role                      = "TF_Developers"
  ssm_parameter_dms_username    = "/dms/username"
  ssm_parameter_dms_password    = "/dms/password"
  source_endpoint_id            = "test-source-manual-123"
  source_endpoint_engine_name   = "sqlserver"
  source_endpoint_server_name   = "m1rf-cyber.ctcxkxuqjgzd.us-west-2.rds.amazonaws.com"
  source_endpoint_database_name = "m1rf-cyber"
  source_endpoint_ssl_mode      = "require"
  source_endpoint_port          = "1433"
  source_certificate_arn        = null
  s3_target_endpoint_id         = "psps-tahs-s3-target"
  s3_target_bucket_name         = "pge-psps-tahs-dms-target-bucket"
  s3_target_bucket_arn          = "arn:aws:s3:::pge-psps-tahs-dms-target-bucket"
  s3_target_bucket_folder       = "psps-tahs/migration-data"
  s3_data_format                = "csv"
  s3_compression_type           = "GZIP"
  enable_date_partitioning      = true
  date_partition_sequence       = "YYYYMMDD"
  csv_delimiter                 = ","
  csv_row_delimiter             = "\\n"
  include_op_for_full_load      = false
  add_column_name               = true
  s3_encryption_mode            = "SSE_S3"
  s3_kms_key_id                 = null
}
