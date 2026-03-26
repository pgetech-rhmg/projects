run "kinesis_stream_on_demand" {
  command = apply

  module {
    source = "./examples/kinesis_stream_on_demand"
  }
}

variables {
  account_num        = "056672152820"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  kms_role           = "CloudAdmin"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 1234567
  optional_tags = {
    managed_by = "terraform"
  }
  name = "example"
  stream_mode = {
    shard_count         = null
    stream_mode_details = "ON_DEMAND"
  }
  timeouts = {
    create = "10m"
    update = "140m"
    delete = "140m"
  }
  encryption_type = "NONE"
}
