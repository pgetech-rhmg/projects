run "default" {
  command = apply

  module {
    source = "./examples/default"
  }
}

variables {
  aws_region  = "us-west-2"
  aws_role    = "CloudAdmin"
  account_num = "750713712981"
}
