run "workteam" {
  command = apply

  module {
    source = "./examples/workteam"
  }
}

variables {
  account_num        = "056672152820"
  aws_region         = "us-west-2"
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
  optional_tags      = { service = "sagemaker" }
  name               = "test-work"
  workforce_name     = "test"
  client_id          = "14hgs1pg0u43b9fukvav2ttr6q"
  user_pool          = "us-west-2_w1IrYt74K"
  user_group         = "test"
}
