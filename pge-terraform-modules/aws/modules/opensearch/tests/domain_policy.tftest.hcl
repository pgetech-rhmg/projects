run "domain_policy" {
  command = apply

  module {
    source = "./examples/domain_policy"
  }
}

variables {
  account_num = "750713712981"
  aws_region  = "us-west-2"
  aws_role    = "CloudAdmin"
  domain_name = "pgeos-test"
}
