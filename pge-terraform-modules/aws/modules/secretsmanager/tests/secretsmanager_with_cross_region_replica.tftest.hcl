run "secretsmanager_with_cross_region_replica" {
  command = apply

  module {
    source = "./examples/secretsmanager_with_cross_region_replica"
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
  secretsmanager_name        = "test-sm-replica"
  secretsmanager_description = "testing of secrets manager with replica"
  recovery_window_in_days    = 0
  replica_region             = "us-east-1"
  kms_name                   = "sm-cmk-replica"
  kms_description            = "CMK for encrypting secretsmanager with replica"
}
