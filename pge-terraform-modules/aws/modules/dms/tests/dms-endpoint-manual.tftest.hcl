run "dms-endpoint-manual" {
  command = apply

  module {
    source = "./examples/dms-endpoint-manual"
  }
}

variables {
  aws_region                    = "us-west-2"
  account_num                   = "750713712981"
  aws_role                      = "CloudAdmin"
  kms_role                      = "TF_Developers"
  AppID                         = "1001"
  Environment                   = "Dev"
  DataClassification            = "Internal"
  CRIS                          = "Low"
  Notify                        = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                         = ["abc1", "def2", "ghi3"]
  Compliance                    = ["None"]
  Order                         = 8115205
  source_endpoint_id            = "test-source-manual-123"
  source_endpoint_engine_name   = "sqlserver"
  source_endpoint_server_name   = "m1rf-cyber.ctcxkxuqjgzd.us-west-2.rds.amazonaws.com"
  source_endpoint_database_name = "m1rf-cyber"
  source_endpoint_ssl_mode      = "require"
  source_endpoint_port          = "1433"
  source_certificate_arn        = null
  target_endpoint_id            = "test-target-manual-123"
  target_endpoint_engine_name   = "sqlserver"
  target_endpoint_server_name   = "m1rf-cyber.ctcxkxuqjgzd.us-west-2.rds.amazonaws.com"
  target_endpoint_database_name = "m1rf-cyber"
  target_endpoint_ssl_mode      = "require"
  target_endpoint_username      = "testuser"
  target_endpoint_password      = "password123"
  target_endpoint_port          = "1433"
  target_certificate_arn        = null
  ssm_parameter_dms_username    = "/dms/username"
  ssm_parameter_dms_password    = "/dms/password"
  kms_name                      = "test-dms-manual-12111"
  kms_description               = "CMK for encrypting dms"
}
