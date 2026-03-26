account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

AppID              = "1001"                                           # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment        = "Dev"                                            # Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None

optional_tags = { managed_by = "terraform" }

#codedeploy_app_lambda
codedeploy_app_name             = "test_app_lambda"
codedeploy_app_compute_platform = "Lambda"

#deployment_config_lambda
deployment_config_name             = "test_config_lambda"
deployment_config_compute_platform = "Lambda"
traffic_routing_config = {
  type       = "TimeBasedCanary" # Type of traffic routing config
  interval   = 1                 # The number of minutes between the first and second traffic shifts of a TimeBasedCanary deployment
  percentage = 10                # The percentage of traffic to shift in the first increment of a TimeBasedCanary deployment
}

#deployment_group
deployment_group_name = "test-lambda-canary_deployment"
deployment_type       = "BLUE_GREEN"
deployment_option     = "WITH_TRAFFIC_CONTROL"

#vpc_endpoint
api_service_name = "com.amazonaws.us-west-2.codedeploy"

#security_group_vpc_endpoint
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

#deployment_group_role
role_name   = "test_deploy_role"
aws_service = ["codedeploy.amazonaws.com"]
policy_arns = ["arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"]

#paramter_names
ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"