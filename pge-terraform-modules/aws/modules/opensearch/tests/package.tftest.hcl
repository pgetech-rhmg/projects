run "package" {
  command = apply

  module {
    source = "./examples/package"
  }
}

variables {
  account_num         = "750713712981"
  aws_region          = "us-west-2"
  aws_role            = "CloudAdmin"
  domain_name         = "pgeos-test"
  package_name        = "pgeos-test-a8t"
  package_description = "testing package"
  s3_bucket_name      = "ccoe-opensearch-test"
  s3_key              = "tfc.txt"
}
