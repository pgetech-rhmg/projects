run "endpoint_config_serverless" {
  command = apply

  module {
    source = "./examples/endpoint_config_serverless"
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
  name               = "serverless-endpoint-config-tf-test"
  model_name         = "IAC-TEST"
  variant_name       = "variant-1"
  serverless_config = {
    max_concurrency   = 1
    memory_size_in_mb = 1024
  }
}
