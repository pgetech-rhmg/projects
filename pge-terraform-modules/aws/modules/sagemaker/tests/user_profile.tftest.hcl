run "user_profile" {
  command = apply

  module {
    source = "./examples/user_profile"
  }
}

variables {
  account_num                               = "056672152820"
  aws_region                                = "us-west-2"
  aws_role                                  = "CloudAdmin"
  AppID                                     = "1001"
  Environment                               = "Dev"
  DataClassification                        = "Internal"
  CRIS                                      = "Low"
  Notify                                    = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                                     = ["abc1", "def2", "ghi3"]
  Compliance                                = ["None"]
  Order                                     = 8115205
  optional_tags                             = { service = "sagemaker" }
  ssm_parameter_subnet_id1                  = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2                  = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3                  = "/vpc/2/privatesubnet3/id"
  ssm_parameter_vpc_id                      = "/vpc/id"
  user_profile_role_service                 = ["sagemaker.amazonaws.com"]
  name                                      = "test-user"
  domain_id                                 = "d-g4dw003xouip"
  notebook_output_option                    = "Allowed"
  jupyter_server_app_settings_instance_type = "system"
  tensor_board_app_settings_instance_type   = "ml.g4dn.xlarge"
  kernel_gateway_app_settings_instance_type = "ml.g4dn.xlarge"
  studio_lifecycle_config_app_type          = "JupyterServer"
  studio_lifecycle_config_content           = "studio_lifecycle_config_content.sh"
}
