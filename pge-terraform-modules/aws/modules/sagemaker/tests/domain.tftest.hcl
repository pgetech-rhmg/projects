run "domain" {
  command = apply

  module {
    source = "./examples/domain"
  }
}

variables {
  account_num                                             = "056672152820"
  aws_region                                              = "us-west-2"
  aws_role                                                = "CloudAdmin"
  kms_role                                                = "TF_Developers"
  AppID                                                   = "1001"
  Environment                                             = "Dev"
  DataClassification                                      = "Internal"
  CRIS                                                    = "Low"
  Notify                                                  = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                                                   = ["abc1", "def2", "ghi3"]
  Compliance                                              = ["None"]
  Order                                                   = 8115205
  optional_tags                                           = { service = "sagemaker" }
  ssm_parameter_subnet_id1                                = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2                                = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3                                = "/vpc/2/privatesubnet3/id"
  ssm_parameter_vpc_id                                    = "/vpc/id"
  name                                                    = "test-domain"
  notebook_output_option                                  = "Allowed"
  home_efs_file_system                                    = "Delete"
  jupyter_server_app_settings_instance_type               = "system"
  tensor_board_app_settings_instance_type                 = "ml.g4dn.xlarge"
  kernel_gateway_app_settings_instance_type               = "ml.g4dn.xlarge"
  jupyter_server_app_settings_lifecycle_config_arn        = "arn:aws:sagemaker:us-west-2:056672152820:studio-lifecycle-config/test-studio-lifecycle-config-sag5lmyu"
  jupyter_server_app_settings_lifecycle_config_arns       = ["arn:aws:sagemaker:us-west-2:056672152820:studio-lifecycle-config/test-studio-lifecycle-config-sag5lmyu"]
  kernel_gateway_app_settings_lifecycle_config_arn        = "arn:aws:sagemaker:us-west-2:056672152820:studio-lifecycle-config/test-studio-lifecycle-config-sag5lmyu"
  kernel_gateway_app_settings_lifecycle_config_arns       = ["arn:aws:sagemaker:us-west-2:056672152820:studio-lifecycle-config/test-studio-lifecycle-config-sag5lmyu"]
  tensor_board_app_settings_lifecycle_config_arn          = "arn:aws:sagemaker:us-west-2:056672152820:studio-lifecycle-config/test-studio-lifecycle-config-sag5lmyu"
  domain_role_service                                     = ["sagemaker.amazonaws.com"]
  default_space_jupyter_server_app_settings_instance_type = "system"
  default_space_kernel_gateway_app_settings_instance_type = "ml.t3.medium"
  tag_propagation                                         = "DISABLED"
}
