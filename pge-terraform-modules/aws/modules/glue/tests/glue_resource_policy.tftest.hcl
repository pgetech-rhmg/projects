run "glue_resource_policy" {
  command = apply

  module {
    source = "./examples/glue_resource_policy"
  }
}

variables {
  aws_region         = "us-west-2"
  account_num        = "056672152820"
  aws_role           = "CloudAdmin"
  glue_enable_hybrid = "TRUE"
  role_name          = "test-new-glue-iac"
}
