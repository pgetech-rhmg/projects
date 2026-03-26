run "app" {
  command = apply

  module {
    source = "./examples/app"
  }
}

variables {
  account_num        = "056672152820"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags      = { service = "sagemaker" }
  name               = "test-sagemaker-app"
  app_type           = "JupyterServer"
  domain_id          = "d-fwq5rl9f4yxb"
  user_profile_name  = "test-sm"
}
