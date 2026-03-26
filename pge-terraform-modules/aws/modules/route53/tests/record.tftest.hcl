run "record" {
  command = apply

  module {
    source = "./examples/record"
  }
}

variables {
  account_num = "514712703977"
  aws_region  = "us-west-2"
  aws_role    = "CloudAdmin"
  zone_id     = "Z1PO7XO596QKJW"
}
