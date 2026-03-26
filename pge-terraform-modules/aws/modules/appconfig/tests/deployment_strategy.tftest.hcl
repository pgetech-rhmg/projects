run "deployment_strategy" {
  command = apply

  module {
    source = "./examples/deployment_strategy"
  }
}

variables {
  account_num         = "750713712981"
  aws_region          = "us-west-2"
  aws_role            = "CloudAdmin"
  AppID               = "1001"
  Environment         = "Dev"
  DataClassification  = "Internal"
  CRIS                = "Low"
  Notify              = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner               = ["abc1", "def2", "ghi3"]
  Compliance          = ["None"]
  name                = "inspect-ccoe"
  description         = "Kill Switch Feature Flags Other App Configurations"
  deployment_duration = 100
  bake_time           = 100
  replicate_to        = "NONE"
  growth_factor       = 100
  growth_type         = "LINEAR"
}
