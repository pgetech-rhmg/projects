run "data_catalog_encryption_settings" {
  command = apply

  module {
    source = "./examples/data_catalog_encryption_settings"
  }
}

variables {
  aws_region         = "us-west-2"
  account_num        = "056672152820"
  aws_role           = "CloudAdmin"
  kms_role           = "TF_Developers"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags      = { service = "glue" }
  name               = "example"
}
