run "standard_queue_with_custom_policy" {
  command = apply

  module {
    source = "./examples/standard_queue_with_custom_policy"
  }
}

variables {
  account_num         = "056672152820"
  aws_region          = "us-west-2"
  aws_role            = "CloudAdmin"
  kms_role            = "CloudAdmin"
  AppID               = "1001"
  Environment         = "Dev"
  DataClassification  = "Internal"
  CRIS                = "Low"
  Notify              = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner               = ["abc1", "def2", "ghi3"]
  Compliance          = ["None"]
  Optional_tags       = { pge_team = "ccoe-tf-developers" }
  sqs_name            = "test-standard"
  custom_policy       = "custom_policy.json"
  sqs_deadletter_name = "test-deadletter"
  kms_name            = "sqs-cmk"
  kms_description     = "CMK for sqs standard queue"
}
