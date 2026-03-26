run "dynamodb_global_table" {
  command = apply

  module {
    source = "./examples/dynamodb_global_table"
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
  table_name         = "test-dynamodb-123-oxdi"
  hash_key           = "UserId"
  hash_range_key_attributes = [
    {
      name = "UserId"
      type = "S"
    }
  ]
  create_replica   = false
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  kms_name         = "kms-dynamodb-123"
  kms_description  = "CMK for encrypting dynamodb global table"
}
