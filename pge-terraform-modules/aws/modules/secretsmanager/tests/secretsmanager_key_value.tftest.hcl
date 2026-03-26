run "secretsmanager_key_value" {
  command = apply

  module {
    source = "./examples/secretsmanager_key_value"
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
  secretsmanager_name        = "test-sm-keyvalue"
  secretsmanager_description = "testing of secrets manager with secret string as key value pairs"
  recovery_window_in_days    = 0
  secret_version_enabled     = true
  secret_string              = { key1 = "value1", key2 = "value2" }
  kms_name                   = "sm-cmk-keyvalue"
  kms_description            = "CMK for encrypting secretsmanager with secret string as key value pairs"
}
