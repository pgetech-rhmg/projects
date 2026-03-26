run "kms_customized_policy" {
  command = apply

  module {
    source = "./examples/kms_customized_policy"
  }
}

variables {
  account_num        = "750713712981"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  kms_role           = "TF_Developers"
  template_file_name = "kms_user_policy.json"
  user               = "s7aw"
  name               = "ccoe_tfe_custom"
  description        = "KMS key for ccoe"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags = {
  }
}
