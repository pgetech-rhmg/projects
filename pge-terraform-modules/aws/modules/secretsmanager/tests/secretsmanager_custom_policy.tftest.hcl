run "secretsmanager_custom_policy" {
  command = apply

  module {
    source = "./examples/secretsmanager_custom_policy"
  }
}

variables {
  account_num                = "750713712981"
  aws_region                 = "us-west-2"
  aws_role                   = "CloudAdmin"
  kms_role                   = "CloudAdmin"
  AppID                      = "1001"
  Environment                = "Dev"
  DataClassification         = "Internal"
  CRIS                       = "Low"
  Notify                     = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                      = ["abc1", "def2", "ghi3"]
  Compliance                 = ["None"]
  Order                      = 8115205
  secretsmanager_name        = "test-sm-custom-policy"
  secretsmanager_description = "testing of the secrets manager for custom policy"
  recovery_window_in_days    = 0
  policy_file_name           = "test_policy.json"
  kms_name                   = "sm-cmk-custom"
  kms_description            = "CMK for encrypting secretsmanager for custom policy"
}
