run "image_version" {
  command = apply

  module {
    source = "./examples/image_version"
  }
}

variables {
  account_num = "514712703977"
  aws_region  = "us-west-2"
  aws_role    = "CloudAdmin"
  image_name  = "amznlnx-iac-test"
  base_image  = "514712703977.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:sample-java"
}
