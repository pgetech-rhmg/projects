run "secretsmanager_binary" {
  command = apply

  module {
    source = "./examples/secretsmanager_binary"
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
  secretsmanager_name        = "test-sm-binary"
  secretsmanager_description = "testing of secrets manager with secret string as  binary"
  recovery_window_in_days    = 0
  secret_version_enabled     = true
  secret_binary              = "dGVzdA=="
  kms_name                   = "sm-cmk-binary"
  kms_description            = "CMK for encrypting secrets manager with secret binary"
}
