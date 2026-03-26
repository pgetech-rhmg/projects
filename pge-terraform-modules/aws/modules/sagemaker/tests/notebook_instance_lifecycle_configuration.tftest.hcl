run "notebook_instance_lifecycle_configuration" {
  command = apply

  module {
    source = "./examples/notebook_instance_lifecycle_configuration"
  }
}

variables {
  account_num = "056672152820"
  aws_region  = "us-west-2"
  aws_role    = "CloudAdmin"
  name        = "test-config"
  on_create   = "echo foo"
  on_start    = "echo bar"
}
