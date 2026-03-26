run "snapshot" {
  command = apply

  module {
    source = "./examples/snapshot"
  }
}

variables {
  account_num                   = "056672152820"
  aws_region                    = "us-west-2"
  aws_role                      = "CloudAdmin"
  kms_role                      = "TF_Developers"
  AppID                         = "1001"
  Environment                   = "Dev"
  DataClassification            = "Internal"
  CRIS                          = "Low"
  Notify                        = ["abc1@pge.com", "def2@pge.com"]
  Owner                         = ["abc1", "def2", "ghi3"]
  Compliance                    = ["None"]
  optional_tags                 = { service = "redshift" }
  name                          = "redshift-test"
  ssm_parameter_subnet_id1      = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2      = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3      = "/vpc/2/privatesubnet3/id"
  ssm_parameter_vpc_id          = "/vpc/id"
  snapshot_schedule_definitions = ["cron(45 15 *)"]
  source_type                   = null
  enabled                       = true
  event_categories              = ["pending"]
  source_ids                    = null
  endpoint                      = "test@pge.com"
  protocol                      = "email"
  template_file_name            = "kms_user_policy.json"
  destination_region            = "us-east-1"
  retention_period              = 1
  node_type                     = "ra3.xlplus"
  cluster_type                  = "single-node"
  skip_final_snapshot           = true
  cluster_role_service          = ["redshift.amazonaws.com", "scheduler.redshift.amazonaws.com"]
  s3_key_prefix                 = "redshift/"
  create_duration               = "10m"
  Order                         = 8115205
}
