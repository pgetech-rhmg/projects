run "model_package_group_policy" {
  command = apply

  module {
    source = "./examples/model_package_group_policy"
  }
}

variables {
  account_num              = "056672152820"
  aws_region               = "us-west-2"
  aws_role                 = "CloudAdmin"
  model_package_group_name = "test-123"
}
