run "windows_file_system" {
  command = apply

  module {
    source = "./examples/windows_file_system"
  }
}

variables {
  account_num                        = "750713712981"
  aws_region                         = "us-west-2"
  aws_role                           = "CloudAdmin"
  kms_role                           = "TF_Developers"
  AppID                              = "1001"
  Environment                        = "Dev"
  DataClassification                 = "Internal"
  CRIS                               = "Low"
  Notify                             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                              = ["abc1", "def2", "ghi3"]
  Compliance                         = ["None"]
  Order                              = 8115205
  optional_tags                      = { managed_by = "terraform" }
  ssm_parameter_vpc_id               = "/vpc/id"
  ssm_parameter_subnet_id1           = "/vpc/privatesubnet3/id"
  name                               = "windows_test"
  file_system_type                   = "windows"
  storage_capacity                   = 32
  deployment_type                    = "SINGLE_AZ_1"
  storage_type                       = "SSD"
  throughput_capacity                = 32
  windows_shared_active_directory_id = "d-926705cff6"
  file_access_audit_log_level        = "SUCCESS_AND_FAILURE"
  file_share_access_audit_log_level  = "SUCCESS_AND_FAILURE"
  skip_final_backup                  = true
  file_system_timeouts = {
    create = "45m"
    update = "45m"
    delete = "60m"
  }
}
