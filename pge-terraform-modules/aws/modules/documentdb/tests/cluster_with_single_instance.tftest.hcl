run "cluster_with_single_instance" {
  command = apply

  module {
    source = "./examples/cluster_with_single_instance"
  }
}

variables {
  account_num                 = "750713712981"
  aws_region                  = "us-west-2"
  aws_role                    = "CloudAdmin"
  kms_role                    = "CloudAdmin"
  AppID                       = "1001"
  Environment                 = "Dev"
  DataClassification          = "Internal"
  CRIS                        = "Low"
  Notify                      = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                       = ["abc1", "def2", "ghi3"]
  Compliance                  = ["None"]
  optional_tags               = { managed_by = "terraform" }
  Order                       = 8115205
  ssm_parameter_vpc_id        = "/vpc/id"
  ssm_parameter_subnet_id1    = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2    = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3    = "/vpc/2/privatesubnet3/id"
  name                        = "docdb-test"
  cluster_engine_version      = "4.0.0"
  cluster_skip_final_snapshot = true
  cluster_timeouts = {
    create = "120m"
    update = "120m"
    delete = "120m"
  }
  docdb_cluster_parameter_group_family = "docdb4.0"
  parameter = [{
    name  = "change_stream_log_retention_duration"
    value = 10800
    },
    {
      name         = "profiler"
      value        = "disabled"
      apply_method = "immediate"
    },
    {
      name  = "profiler_sampling_rate"
      value = 1.0
    },
    {
      name         = "profiler_threshold_ms"
      value        = 100
      apply_method = "immediate"
    },
    {
      name  = "ttl_monitor"
      value = "enabled"
  }]
  cluster_instance_instance_class = "db.t3.medium"
}
