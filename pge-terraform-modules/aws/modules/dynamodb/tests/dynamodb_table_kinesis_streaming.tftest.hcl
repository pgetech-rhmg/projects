run "dynamodb_table_kinesis_streaming" {
  command = apply

  module {
    source = "./examples/dynamodb_table_kinesis_streaming"
  }
}

variables {
  aws_region         = "us-west-2"
  account_num        = "750713712981"
  aws_role           = "CloudAdmin"
  kms_role           = "CloudAdmin"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  table_name         = "dynamodb_table-1.2"
  hash_key           = "UserId"
  range_key          = "title"
  hash_range_key_attributes = [
    {
      name = "UserId"
      type = "S"
    },
    {
      name = "title"
      type = "S"
    },
    {
      name = "age"
      type = "N"
    }
  ]
  local_secondary_indexes = [
    {
      name               = "TitleIndex"
      hash_key           = "title"
      range_key          = "age"
      projection_type    = "INCLUDE"
      non_key_attributes = ["UserId"]
    }
  ]
  ttl_enabled                = true
  ttl_attribute_name         = "ttl_dynamo_table"
  stream_enabled             = true
  stream_view_type           = "NEW_AND_OLD_IMAGES"
  kms_name                   = "dynamodb_kms"
  kms_description            = "CMK for encrypting dynamodb"
  kinesis_stream_name        = "dynamodb-logging-kinesis-stream"
  kinesis_stream_shard_count = 1
}
