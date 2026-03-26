run "configuration_profile" {
  command = apply

  module {
    source = "./examples/configuration_profile"
  }
}

variables {
  account_num        = "750713712981"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  kms_role           = "CloudAdmin"
  kms_name           = "ccoe-kms-appconfig-example"
  kms_description    = "A test key created for the AppConfig TF module"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  application_id     = "3jcwgsa"
  name               = "ccoe-config-profile-1"
}
