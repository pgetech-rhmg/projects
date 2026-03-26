account_num = "514712703977"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

AppID              = "1001"
Environment        = "Dev"
DataClassification = "Internal"
CRIS               = "Low"
Notify             = ["abc1@pge.com", "def2@pge.com"]
Owner              = ["abc1", "def2", "ghi3"]
Compliance         = ["None"]
Order              = 8115205
optional_tags      = { "service" = "appstream-2.0-private" }

# Supporting Resource - MUST BE PRIVATE SUBNETS WITHOUT INTERNET GATEWAY
# Updated to use subnets that match existing AppStream VPC endpoint
ssm_parameter_vpc_id     = "/vpc/id"                # VPC with NO internet gateway
ssm_parameter_subnet_id1 = "/vpc/privatesubnet1/id" # subnet-f9206980 (us-west-2a)
ssm_parameter_subnet_id2 = "/vpc/privatesubnet2/id" # subnet-639df628 (us-west-2b)
ssm_parameter_subnet_id3 = "/vpc/privatesubnet3/id" # subnet-1b085341 (us-west-2c) - matches VPC endpoint

# IAM
role_service = ["appstream.amazonaws.com"]

# VPC Endpoint Configuration
appstream_service_name = "com.amazonaws.us-west-2.appstream.streaming"

# Fleet Configuration
name              = "ccoe-appstream-private-vpce"
instance_type     = "stream.standard.small"
fleet_type        = "ALWAYS_ON"
desired_instances = 2
image_name        = "ArcPro_3_3_v2"

# Stack Configuration
description  = "AppStream 2.0 Stack with VPC Endpoints for private connectivity - Managed by Terraform"
display_name = "ccoe-appstream-private-stack"

# Domain join configuration
# domain_join_info = {
#   directory_name                         = "azure.pge.com"
#   organizational_unit_distinguished_name = "OU=AppStream,OU=Applications,OU=Prod,DC=azure,DC=pge,DC=com"
# }