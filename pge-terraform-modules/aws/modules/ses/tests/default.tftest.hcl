run "default" {
  command = apply

  module {
    source = "./examples/default"
  }
}

variables {
  account_num                = "056672152820"
  aws_region                 = "us-west-2"
  aws_role                   = "CloudAdmin"
  ses_configuration_set_name = "ses_ccoe_example"
}
