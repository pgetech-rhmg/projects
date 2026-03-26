run "multi_node_cluster" {
  command = apply

  module {
    source = "./examples/multi_node_cluster"
  }
}

variables {
  account_num                          = "056672152820"
  aws_region                           = "us-west-2"
  aws_role                             = "CloudAdmin"
  kms_role                             = "TF_Developers"
  AppID                                = "1001"
  Environment                          = "Dev"
  DataClassification                   = "Internal"
  CRIS                                 = "Low"
  Notify                               = ["abc1@pge.com", "def2@pge.com"]
  Owner                                = ["abc1", "def2", "ghi3"]
  Compliance                           = ["None"]
  optional_tags                        = { service = "redshift" }
  name                                 = "redshift-test"
  ssm_parameter_vpc_id                 = "/vpc/id"
  ssm_parameter_subnet_id1             = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2             = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3             = "/vpc/2/privatesubnet3/id"
  authentication_profile_content       = "authentication_profile_policy.json"
  AllowDBUserOverride                  = "1"
  Client_ID                            = "ExampleClientID"
  App_ID                               = "example"
  breach_action                        = "log"
  amount                               = 10
  period                               = "daily"
  node_type                            = "ra3.xlplus"
  cluster_type                         = "multi-node"
  number_of_nodes                      = 2
  skip_final_snapshot                  = true
  cluster_role_service                 = ["redshift.amazonaws.com", "scheduler.redshift.amazonaws.com"]
  availability_zone_relocation_enabled = true
  availability_zone                    = "us-west-2c"
  s3_key_prefix                        = "redshift/"
  create_duration                      = "10m"
  Order                                = 8115205
}
