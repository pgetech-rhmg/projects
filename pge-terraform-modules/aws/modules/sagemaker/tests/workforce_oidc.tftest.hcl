run "workforce_oidc" {
  command = apply

  module {
    source = "./examples/workforce_oidc"
  }
}

variables {
  account_num = "514712703977"
  aws_region  = "us-west-2"
  aws_role    = "CloudAdmin"
  name        = "test-workforce-oidc"
  cidrs       = ["10.0.0.0/24"]
}
