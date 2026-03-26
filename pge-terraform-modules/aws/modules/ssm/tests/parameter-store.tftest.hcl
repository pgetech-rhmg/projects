run "parameter-store" {
  command = apply

  module {
    source = "./examples/parameter-store"
  }
}

variables {
  account_num        = "750713712981"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  kms_role           = "CloudAdmin"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  name               = "/terraform/test/string"
  value              = "John,Toddy"
  kms_name           = "pge-ssm-kms-ps"
  kms_description    = "The description of the key as viewed in AWS console."
}
