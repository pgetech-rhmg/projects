run "app_image_config" {
  command = apply

  module {
    source = "./examples/app_image_config"
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
  name               = "test-app-image-config"
  default_gid        = 0
  default_uid        = 0
}
