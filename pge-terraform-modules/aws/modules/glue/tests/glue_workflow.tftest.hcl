run "glue_workflow" {
  command = apply

  module {
    source = "./examples/glue_workflow"
  }
}

variables {
  aws_region         = "us-west-2"
  account_num        = "056672152820"
  aws_role           = "CloudAdmin"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags      = { service = "glue" }
  name               = "Test-3"
  glue_workflow_default_run_properties = {
    "name" = "workflow_name"
  }
  glue_workflow_max_concurrent_runs = "1"
}
