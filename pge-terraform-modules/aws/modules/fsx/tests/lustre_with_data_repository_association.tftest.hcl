run "lustre_with_data_repository_association" {
  command = apply

  module {
    source = "./examples/lustre_with_data_repository_association"
  }
}

variables {
  account_num                 = "750713712981"
  aws_region                  = "us-west-2"
  aws_role                    = "CloudAdmin"
  kms_role                    = "TF_Developers"
  AppID                       = "1001"
  Environment                 = "Dev"
  DataClassification          = "Internal"
  CRIS                        = "Low"
  Notify                      = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                       = ["abc1", "def2", "ghi3"]
  Compliance                  = ["None"]
  Order                       = 8115205
  optional_tags               = { managed_by = "terraform" }
  ssm_parameter_vpc_id        = "/vpc/id"
  ssm_parameter_subnet_id1    = "/vpc/privatesubnet3/id"
  name                        = "luster-association-test"
  storage_capacity            = 1200
  per_unit_storage_throughput = 125
  log_configuration_level     = "WARN_ERROR"
  file_system_path            = "/ns"
  auto_import_policy_events   = ["NEW", "CHANGED"]
  auto_export_policy_events   = ["NEW", "DELETED"]
  data_repository_association_timeouts = {
    create = "10m"
    update = "10m"
    delete = "20m"
  }
}
