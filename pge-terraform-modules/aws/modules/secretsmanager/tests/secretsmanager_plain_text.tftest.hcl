run "secretsmanager_plain_text" {
  command = apply

  module {
    source = "./examples/secretsmanager_plain_text"
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
  secretsmanager_name        = "test-sm-plain-text"
  secretsmanager_description = "testing of secrets manager with secret string using a plain text"
  recovery_window_in_days    = 0
  secret_version_enabled     = true
  secret_string              = "test"
  kms_name                   = "sm-cmk-plain-text"
  kms_description            = "CMK for encrypting secrets manager with secret string using a plain text"
}
