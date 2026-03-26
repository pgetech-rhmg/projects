data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "mrad_vpc" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${var.aws_account}-VPC"]
  }
}

data "aws_vpc_endpoint" "apigw" {
  vpc_id       = data.aws_vpc.mrad_vpc.id
  service_name = "com.amazonaws.us-west-2.execute-api"
}