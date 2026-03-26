run "lambda_canary" {
  command = apply

  module {
    source = "./examples/lambda_canary"
  }
}

variables {
  account_num                        = "750713712981"
  aws_region                         = "us-west-2"
  aws_role                           = "CloudAdmin"
  AppID                              = "1001"
  Environment                        = "Dev"
  DataClassification                 = "Internal"
  CRIS                               = "Low"
  Notify                             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                              = ["abc1", "def2", "ghi3"]
  Compliance                         = ["None"]
  optional_tags                      = { managed_by = "terraform" }
  codedeploy_app_name                = "test_app_lambda"
  codedeploy_app_compute_platform    = "Lambda"
  deployment_config_name             = "test_config_lambda"
  deployment_config_compute_platform = "Lambda"
  Order                              = 8115205
  traffic_routing_config = {
    type       = "TimeBasedCanary"
    interval   = 1
    percentage = 10
  }
  deployment_group_name       = "test-lambda-canary_deployment"
  deployment_type             = "BLUE_GREEN"
  deployment_option           = "WITH_TRAFFIC_CONTROL"
  api_service_name            = "com.amazonaws.us-west-2.codedeploy"
  vpc_endpoint_sg_name        = "test_vpc_endpont_sg"
  vpc_endpoint_sg_description = "Security group for vpc endpoint"
  vpc_endpoint_cidr_ingress_rules = [{
    from             = 5701,
    to               = 5703,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  vpc_endpoint_cidr_egress_rules = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  role_name                = "test_deploy_role"
  aws_service              = ["codedeploy.amazonaws.com"]
  policy_arns              = ["arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"]
  ssm_parameter_vpc_id     = "/vpc/id"
  ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
}
