run "sns_custom_policy" {
  command = apply

  module {
    source = "./examples/sns_custom_policy"
  }
}

variables {
  account_num           = "056672152820"
  aws_region            = "us-west-2"
  aws_role              = "CloudAdmin"
  AppID                 = "1001"
  Environment           = "Dev"
  DataClassification    = "Internal"
  CRIS                  = "Low"
  Notify                = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                 = ["abc1", "def2", "ghi3"]
  Compliance            = ["None"]
  Order                 = 8115205
  snstopic_name         = "sns_ccoe_example"
  snstopic_display_name = "sns_ccoe_example"
  policy_file_name      = "test_policy.json"
}
