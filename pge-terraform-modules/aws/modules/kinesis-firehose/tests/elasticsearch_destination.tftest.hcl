run "elasticsearch_destination" {
  command = apply

  module {
    source = "./examples/elasticsearch_destination"
  }
}

variables {
  account_num        = "056672152820"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  kms_role           = "DatabaseAdmin"
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
  index_name                          = "elasticsearch_test"
  cluster_endpoint                    = null
  buffering_interval                  = 300
  buffering_size                      = 5
  index_rotation_period               = "OneDay"
  s3_backup_mode                      = "FailedDocumentsOnly"
  type_name                           = "elasticsearch"
  retry_duration                      = 300
  elasticsearch_log_stream_name       = "elasticsearch_log"
  processing_configuration_enabled    = false
  processing_configuration_processors = []
  path                                = "/"
  aws_service                         = ["firehose.amazonaws.com", "opensearchservice.amazonaws.com"]
  ssm_parameter_subnet_id1            = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2            = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3            = "/vpc/2/privatesubnet3/id"
  parameter_vpc_id_name               = "/vpc/id"
  domain_name                         = "elasticsearch-test-oxdi"
  instance_count                      = 2
  zone_awareness_enabled              = true
  instance_type                       = "t2.small.elasticsearch"
  ebs_enabled                         = true
  volume_size                         = 10
}
