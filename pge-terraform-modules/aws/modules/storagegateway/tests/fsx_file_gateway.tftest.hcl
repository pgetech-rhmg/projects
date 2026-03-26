run "fsx_file_gateway" {
  command = apply

  module {
    source = "./examples/fsx_file_gateway"
  }
}

variables {
  account_num                          = "056672152820"
  aws_region                           = "us-west-2"
  aws_role                             = "CloudAdmin"
  kms_role                             = "CloudAdmin"
  AppID                                = "2102"
  Environment                          = "Dev"
  DataClassification                   = "Internal"
  CRIS                                 = "Low"
  Notify                               = ["abc1@pge.com", "def2@pge.com"]
  Owner                                = ["abc1", "def2", "ghi3"]
  Compliance                           = ["None"]
  optional_tags                        = { service = "storagegateway" }
  Order                                = 8115205
  secretsmanager_name                  = "storagegateway-activation-key"
  secretsmanager_description           = "Activation key for storage gateway"
  secret_version_enabled               = true
  fsx_file_system_association_username = "fsx_association_username"
  fsx_file_system_association_password = "fsx_association_password"
  ssm_parameter_activation_key         = "/storagegateway/activationkey"
  name                                 = "tf-test-fsx-file-system"
  gateway_timezone                     = "GMT-4:00"
  gateway_type                         = "FILE_FSX_SMB"
  gateway_vpc_endpoint                 = "vpce-0e12576fa3ac6b7d5"
  smb_security_strategy                = "MandatorySigning"
  domain_name                          = "pge.com"
  password                             = "password"
  username                             = "username"
  logs_name                            = "/aws/vendedlogs/sgw-fsx"
  disk_node                            = "/dev/sdb"
  ssm_parameter_vpc_id                 = "/vpc/id"
  ssm_parameter_subnet_id1             = "/vpc/2/privatesubnet1/id"
  cache_stale_timeout_in_seconds       = 300
  timeouts = {
    create = "15m"
    delete = "20m"
    update = "15m"
  }
  file_system_type                   = "windows"
  storage_capacity                   = 32
  deployment_type                    = "SINGLE_AZ_1"
  storage_type                       = "SSD"
  throughput_capacity                = 32
  windows_shared_active_directory_id = "d-92670c4e30"
  file_access_audit_log_level        = "SUCCESS_AND_FAILURE"
  file_share_access_audit_log_level  = "SUCCESS_AND_FAILURE"
  skip_final_backup                  = true
  file_system_timeouts = {
    create = "45m"
    update = "45m"
    delete = "60m"
  }
  aws_service = ["s3.amazonaws.com"]
  policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
}
