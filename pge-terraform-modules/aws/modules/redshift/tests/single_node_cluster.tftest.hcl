run "single_node_cluster" {
  command = apply

  module {
    source = "./examples/single_node_cluster"
  }
}

variables {
  account_num              = "056672152820"
  aws_region               = "us-west-2"
  aws_role                 = "CloudAdmin"
  kms_role                 = "TF_Developers"
  AppID                    = "1001"
  Environment              = "Dev"
  DataClassification       = "Internal"
  CRIS                     = "Low"
  Notify                   = ["abc1@pge.com", "def2@pge.com"]
  Owner                    = ["abc1", "def2", "ghi3"]
  Compliance               = ["None"]
  optional_tags            = { service = "redshift" }
  name                     = "redshift-test"
  ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"
  schedule                 = "cron(0 22 * * ? *)"
  role_service             = ["redshift.amazonaws.com", "scheduler.redshift.amazonaws.com"]
  classic                  = false
  resize_cluster_type      = "multi-node"
  resize_node_type         = "dc2.large"
  resize_number_of_nodes   = 2
  pause_cluster_schedule   = "cron(0 10 ? * MON *)"
  resume_cluster_schedule  = "cron(0 10 ? * WED *)"
  resize_cluster_schedule  = "cron(0 10 ? * THU *)"
  parameter_vpc_id_name    = "/vpc/id"
  node_type                = "ra3.xlplus"
  cluster_type             = "single-node"
  skip_final_snapshot      = true
  cluster_role_service     = ["redshift.amazonaws.com", "scheduler.redshift.amazonaws.com"]
  s3_key_prefix            = "redshift/"
  create_duration          = "10m"
  Order                    = 8115205
}
