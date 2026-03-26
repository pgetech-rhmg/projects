run "studio_lifecycle_config" {
  command = apply

  module {
    source = "./examples/studio_lifecycle_config"
  }
}

variables {
  account_num                      = "056672152820"
  aws_region                       = "us-west-2"
  aws_role                         = "CloudAdmin"
  AppID                            = "1001"
  Environment                      = "Dev"
  DataClassification               = "Internal"
  CRIS                             = "Low"
  Notify                           = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                            = ["abc1", "def2", "ghi3"]
  Compliance                       = ["None"]
  Order                            = 8115205
  optional_tags                    = { service = "sagemaker" }
  name                             = "test-studio-lifecycle-config"
  studio_lifecycle_config_app_type = "JupyterServer"
  studio_lifecycle_config_content  = "studio_lifecycle_config_content.sh"
}
