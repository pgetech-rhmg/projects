run "redshift_destination" {
  command = apply

  module {
    source = "./examples/redshift_destination"
  }
}

variables {
  account_num        = "056672152820"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  kms_role           = "TF_Developers"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags = {
    managed_by = "terraform"
  }
  name                                = "example"
  kinesis_stream_arn                  = null
  kinesis_stream_role_arn             = null
  prefix                              = null
  s3_buffer_size                      = 5
  s3_buffer_interval                  = 300
  compression_format                  = "UNCOMPRESSED"
  error_output_prefix                 = null
  s3_log_stream_name                  = "s3_log"
  retry_duration                      = 3600
  copy_options                        = null
  data_table_columns                  = null
  redshift_log_stream_name            = "redshift_log"
  s3_backup_mode                      = "Enabled"
  s3_backup_prefix                    = null
  s3_backup_buffer_size               = 5
  s3_backup_buffer_interval           = 300
  s3_backup_compression_format        = "UNCOMPRESSED"
  s3_backup_error_output_prefix       = null
  s3_backup_log_stream_name           = "s3_backup_log"
  processing_configuration_enabled    = false
  processing_configuration_processors = []
  path                                = "/"
  aws_service                         = ["firehose.amazonaws.com", "redshift.amazonaws.com"]
  ssm_parameter_subnet_id1            = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2            = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3            = "/vpc/2/privatesubnet3/id"
  parameter_vpc_id_name               = "/vpc/id"
  node_type                           = "ra3.xlplus"
  cluster_type                        = "single-node"
  skip_final_snapshot                 = true
  s3_key_prefix                       = "redshift/"
  database_name                       = "database01"
  create_duration                     = "05m"
}
