run "parameter-store-custom-anomaly-configuration" {
  command = apply

  module {
    source = "./examples/parameter-store-custom-anomaly-configuration"
  }
}

variables {
  account_num                = "750713712981"
  aws_region                 = "us-east-1"
  aws_role                   = "CloudAdmin"
  AppID                      = "1001"
  Environment                = "Dev"
  DataClassification         = "Internal"
  CRIS                       = "Low"
  Notify                     = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                      = ["abc1", "def2", "ghi3"]
  Compliance                 = ["None"]
  Order                      = 8115205
  custom_email_address_value = "abcd@pge.com,efgh@pge.com"
  custom_threshold_value     = "400"
}
