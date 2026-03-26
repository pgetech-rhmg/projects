run "workforce_cognito" {
  command = apply

  module {
    source = "./examples/workforce_cognito"
  }
}

variables {
  account_num = "514712703977"
  aws_region  = "us-west-2"
  aws_role    = "CloudAdmin"
  name        = "test-workforce-cognito"
  cidrs       = ["10.0.0.0/24"]
}
