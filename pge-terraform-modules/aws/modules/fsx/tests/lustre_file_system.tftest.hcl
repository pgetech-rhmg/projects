run "lustre_file_system" {
  command = apply

  module {
    source = "./examples/lustre_file_system"
  }
}

variables {
  account_num                     = "750713712981"
  aws_region                      = "us-west-2"
  aws_role                        = "CloudAdmin"
  kms_role                        = "TF_Developers"
  AppID                           = "1001"
  Environment                     = "Dev"
  DataClassification              = "Internal"
  CRIS                            = "Low"
  Notify                          = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                           = ["abc1", "def2", "ghi3"]
  Compliance                      = ["None"]
  Order                           = 8115205
  optional_tags                   = { managed_by = "terraform" }
  ssm_parameter_vpc_id            = "/vpc/id"
  ssm_parameter_subnet_id1        = "/vpc/2/privatesubnet1/id"
  name                            = "luster_test"
  file_system_type                = "lustre"
  storage_capacity                = 1200
  deployment_type                 = "PERSISTENT_2"
  storage_type                    = "SSD"
  per_unit_storage_throughput     = 125
  log_configuration_level         = "WARN_ERROR"
  lustre_data_compression_type    = "NONE"
  lustre_file_system_type_version = "2.12"
}
