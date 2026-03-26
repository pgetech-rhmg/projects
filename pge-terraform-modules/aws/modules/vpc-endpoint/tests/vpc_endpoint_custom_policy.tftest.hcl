run "vpc_endpoint_custom_policy" {
  command = apply

  module {
    source = "./examples/vpc_endpoint_custom_policy"
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
  subnet_id1_name    = "/vpc/2/privatesubnet1/id"
  subnet_id2_name    = "/vpc/privatesubnet3/id"
  service_name       = "com.amazonaws.us-west-2.ec2"
  sg_name            = "test_end_sg"
  cidr_ingress_rules = [{
    from             = 5701,
    to               = 5703,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.128/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.108.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  policy_file_name = "test_policy.json"
}
