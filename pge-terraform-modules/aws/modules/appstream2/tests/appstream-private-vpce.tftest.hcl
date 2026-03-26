run "appstream-private-vpce" {
  command = apply

  module {
    source = "./examples/appstream-private-vpce"
  }
}

variables {
  account_num              = "514712703977"
  aws_region               = "us-west-2"
  aws_role                 = "CloudAdmin"
  AppID                    = "1001"
  Environment              = "Dev"
  DataClassification       = "Internal"
  CRIS                     = "Low"
  Notify                   = ["abc1@pge.com", "def2@pge.com"]
  Owner                    = ["abc1", "def2", "ghi3"]
  Compliance               = ["None"]
  Order                    = 8115205
  optional_tags            = { "service" = "appstream-2.0-private" }
  ssm_parameter_vpc_id     = "/vpc/id"
  ssm_parameter_subnet_id1 = "/vpc/privatesubnet1/id"
  ssm_parameter_subnet_id2 = "/vpc/privatesubnet2/id"
  ssm_parameter_subnet_id3 = "/vpc/privatesubnet3/id"
  role_service             = ["appstream.amazonaws.com"]
  appstream_service_name   = "com.amazonaws.us-west-2.appstream.streaming"
  name                     = "ccoe-appstream-private-vpce"
  instance_type            = "stream.standard.small"
  fleet_type               = "ALWAYS_ON"
  desired_instances        = 2
  image_name               = "ArcPro_3_3_v2"
  description              = "AppStream 2.0 Stack with VPC Endpoints for private connectivity - Managed by Terraform"
  display_name             = "ccoe-appstream-private-stack"
}
