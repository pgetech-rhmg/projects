run "cluster_with_two_read_replicas" {
  command = apply

  module {
    source = "./examples/cluster_with_two_read_replicas"
  }
}

variables {
  account_num                    = "056672152820"
  aws_region                     = "us-west-2"
  aws_role                       = "CloudAdmin"
  kms_role                       = "TF_Developers"
  template_file_name             = "kms_user_policy.json"
  AppID                          = "1001"
  Environment                    = "Dev"
  DataClassification             = "Internal"
  CRIS                           = "Low"
  Notify                         = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                          = ["abc1", "def2", "ghi3"]
  Compliance                     = ["None"]
  Order                          = 8115205
  optional_tags                  = { service = "neptune" }
  name                           = "example"
  skip_final_snapshot            = "true"
  engine_version                 = "1.1.0.0"
  instance_count                 = 3
  instance_class                 = "db.t3.medium"
  neptune_cluster_endpoint_type  = "READER"
  neptune_streams_value          = "0"
  neptune_lookup_cache_value     = "0"
  neptune_result_cache_value     = "0"
  neptune_ml_iam_role_value      = "arn:aws:iam::056672152820:role/service-role/AWSNeptuneNotebookRole-test-neptune"
  neptune_ml_endpoint_value      = "vpce-0df3dd90ed9a550f2"
  neptune_dfe_query_engine_value = "enabled"
  neptune_query_timeout_value    = 140000
  ssm_parameter_subnet_id1       = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2       = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3       = "/vpc/2/privatesubnet3/id"
}
