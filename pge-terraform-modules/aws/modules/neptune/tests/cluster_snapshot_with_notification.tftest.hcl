run "cluster_snapshot_with_notification" {
  command = apply

  module {
    source = "./examples/cluster_snapshot_with_notification"
  }
}

variables {
  account_num        = "056672152820"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  kms_role           = "TF_Developers"
  template_file_name = "kms_user_policy.json"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags = {
    managed_by = "terraform"
  }
  name                = "example"
  engine_version      = "1.1.0.0"
  skip_final_snapshot = "true"
  timeouts = {
    create = "140m"
    update = "140m"
    delete = "140m"
  }
  source_type              = "db-cluster-snapshot"
  event_categories         = ["backup", "notification"]
  ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"
}
