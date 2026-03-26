run "vpc_endpoint_service_gateway_load_balancer" {
  command = apply

  module {
    source = "./examples/vpc_endpoint_service_gateway_load_balancer"
  }
}

variables {
  aws_region          = "us-west-2"
  account_num         = "750713712981"
  aws_role            = "CloudAdmin"
  AppID               = "1001"
  Environment         = "Dev"
  DataClassification  = "Internal"
  CRIS                = "Low"
  Notify              = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner               = ["abc1", "def2", "ghi3"]
  Compliance          = ["None"]
  Order               = 8115205
  subnet_id1_name     = "/vpc/2/privatesubnet1/id"
  subnet_id2_name     = "/vpc/privatesubnet4/id"
  acceptance_required = false
  load_balancer_type  = "gateway"
  name                = "vpc-glb"
}
