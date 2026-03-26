run "create_fifo_queue" {
  command = apply

  module {
    source = "./examples/create_fifo_queue"
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
  sqs_name            = "users.fifo"
  sqs_deadletter_name = "test-deadletter.fifo"
  kms_name            = "sqs-cmk-fifo"
  kms_description     = "cmk for encrypting sqs"
}
