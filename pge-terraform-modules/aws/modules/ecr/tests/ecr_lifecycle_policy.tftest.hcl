run "ecr_lifecycle_policy" {
  command = apply

  module {
    source = "./examples/ecr_lifecycle_policy"
  }
}

variables {
  account_num             = "750713712981"
  aws_region              = "us-west-2"
  aws_role                = "CloudAdmin"
  kms_role                = "TF_Developers"
  ecr_name                = "test-ecr"
  lifecycle_policy_enable = true
  lifecycle_policy        = "ecr_lifecycle.json"
  AppID                   = "1001"
  Environment             = "Dev"
  DataClassification      = "Internal"
  CRIS                    = "Low"
  Notify                  = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                   = ["abc1", "def2", "ghi3"]
  Compliance              = ["None"]
  kms_name                = "ecr-cmk-cp-test"
  kms_description         = "CMK for encrypting ECR"
  Order                   = 8115205
  optional_tags = {
    Name     = "test"
    pge_team = "ccoe-tf-developers"
  }
}
