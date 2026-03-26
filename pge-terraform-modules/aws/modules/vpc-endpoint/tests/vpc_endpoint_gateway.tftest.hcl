run "vpc_endpoint_gateway" {
  command = apply

  module {
    source = "./examples/vpc_endpoint_gateway"
  }
}

variables {
  aws_region         = "us-west-2"
  account_num        = "750713712981"
  aws_role           = "CloudAdmin"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  vpc_id_name        = "/vpc/id"
  service_name       = "com.amazonaws.us-west-2.s3"
  route_table_ids    = ["rtb-02b58d41c08ef6e9f"]
}
