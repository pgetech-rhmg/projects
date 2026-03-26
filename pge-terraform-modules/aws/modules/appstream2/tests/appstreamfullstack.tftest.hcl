run "appstreamfullstack" {
  command = apply

  module {
    source = "./examples/appstreamfullstack"
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
  optional_tags            = { "service" = "appstream-2.0" }
  ssm_parameter_vpc_id     = "/vpc/id"
  ssm_parameter_subnet_id1 = "/vpc/privatesubnet1/id"
  ssm_parameter_subnet_id2 = "/vpc/privatesubnet2/id"
  ssm_parameter_subnet_id3 = "/vpc/privatesubnet3/id"
  role_service             = ["appstream.amazonaws.com"]
  name                     = "ccoe-appstream2.0-test"
  instance_type            = "stream.standard.small"
  fleet_type               = "ALWAYS_ON"
  desired_instances        = 2
  image_name               = "ArcPro_3_3_v2"
  description              = "AppStream 2.0 Stack for domain-joined streaming sessions - Managed by Terraform"
  display_name             = "ccoe-appstream-stack"
}
